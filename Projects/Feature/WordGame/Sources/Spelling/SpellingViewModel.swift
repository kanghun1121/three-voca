import Foundation

import SwiftUINavigation

@Observable
@MainActor
public final class SpellingViewModel {

    enum ViewState: Equatable {
        case active
        case correct
        case incorrect
        case revealing
        case completed
    }

    enum SlotState: Equatable {
        case hint(Character)
        case filled(Character)
        case cursor
        case empty
    }

    enum AlertAction {
        case confirmDiscard
    }

    @CasePathable
    enum Destination {
        case alert(AlertState<AlertAction>)
    }

    private(set) var viewState: ViewState = .active
    private(set) var currentWord: GameWord?
    private(set) var wordIndex: Int = 0
    private(set) var totalWords: Int = 0
    private(set) var isReviewRound: Bool = false
    var inputText: String = "" {
        didSet { handleInputChange() }
    }
    var destination: Destination?

    private let words: [GameWord]
    private let onCompleted: () -> Void
    private let onClose: () -> Void

    private var reviewWords: [GameWord] = []
    private var incorrectWordIDs: Set<String> = []
    private var advanceTask: Task<Void, Never>?

    init(words: [GameWord], onCompleted: @escaping () -> Void, onClose: @escaping () -> Void) {
        self.words = words
        self.totalWords = words.count
        self.onCompleted = onCompleted
        self.onClose = onClose
    }

    var slots: [SlotState] {
        guard let word = currentWord else { return [] }
        return word.term.enumerated().map { index, _ in
            // 복습 라운드 첫 번째 슬롯은 힌트
            if isReviewRound && index == 0 {
                let char = word.term[word.term.startIndex]
                return .hint(char.lowercased().first ?? char)
            }
            if index < inputText.count {
                let char = inputText[inputText.index(inputText.startIndex, offsetBy: index)]
                return .filled(char)
            } else if index == inputText.count {
                return .cursor
            } else {
                return .empty
            }
        }
    }

    func start() {
        guard !words.isEmpty else {
            onCompleted()
            return
        }
        showWord(at: 0)
    }

    func closeButtonTapped() {
        destination = .alert(
            AlertState(
                title: TextState("종료하시겠습니까?"),
                message: TextState("게임을 종료하면 학습된 이력은 저장되지 않습니다."),
                buttons: [
                    .destructive(TextState("종료"), action: .send(.confirmDiscard)),
                    .cancel(TextState("취소"))
                ]
            )
        )
    }

    func alertButtonTapped(_ action: AlertAction?) {
        switch action {
        case .confirmDiscard:
            advanceTask?.cancel()
            onClose()
        case .none:
            break
        }
    }

    private func handleInputChange() {
        guard viewState == .active else { return }
        let limit = currentWord?.term.count ?? 0
        var filtered = String(inputText.filter { $0.isLetter }.prefix(limit).lowercased())

        // 복습 라운드: 첫 글자 힌트가 삭제되지 않도록 고정
        if isReviewRound, let firstChar = currentWord?.term.first {
            let hint = String(firstChar).lowercased()
            if !filtered.hasPrefix(hint) { filtered = hint }
        }

        guard inputText == filtered else {
            inputText = filtered
            return
        }
        if inputText.count == limit { validateAnswer() }
    }

    private func validateAnswer() {
        guard viewState == .active, let word = currentWord else { return }
        let answer = word.term.lowercased()

        if inputText == answer {
            viewState = .correct
            advanceTask = Task {
                try? await Task.sleep(for: .milliseconds(600))
                guard !Task.isCancelled else { return }
                showWord(at: wordIndex + 1)
            }
        } else {
            // 복습 라운드가 아닐 때만 복습 목록에 추가 (중복 제외)
            if !isReviewRound && !incorrectWordIDs.contains(word.id) {
                incorrectWordIDs.insert(word.id)
                reviewWords.append(word)
            }
            viewState = .revealing
            advanceTask = Task {
                try? await Task.sleep(for: .milliseconds(1500))
                guard !Task.isCancelled else { return }
                showWord(at: wordIndex + 1)
            }
        }
    }

    private func showWord(at index: Int) {
        let currentWords = isReviewRound ? reviewWords : words
        guard index < currentWords.count else {
            if !isReviewRound && !reviewWords.isEmpty {
                // 복습 라운드 시작 — 별도 안내 없이 바로 진행
                isReviewRound = true
                totalWords = reviewWords.count
                showWord(at: 0)
            } else {
                viewState = .completed
                advanceTask = Task {
                    try? await Task.sleep(for: .milliseconds(800))
                    guard !Task.isCancelled else { return }
                    onCompleted()
                }
            }
            return
        }

        let word = currentWords[index]
        // viewState가 .active가 아닌 상태에서 inputText를 먼저 세팅해야
        // didSet의 guard가 조기 리턴하여 검증 로직을 건너뜀
        if isReviewRound, let firstChar = word.term.first {
            inputText = String(firstChar).lowercased()
        } else {
            inputText = ""
        }
        wordIndex = index
        currentWord = word
        viewState = .active
    }
}
