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
    var destination: Destination?

    private let words: [GameWord]
    private let onCompleted: () -> Void
    private let onClose: () -> Void

    private var reviewWords: [GameWord] = []
    private var incorrectWordIDs: Set<String> = []
    private var advanceTask: Task<Void, Never>?

    var slots: [SlotState] {
        guard let word = currentWord else { return [] }
        return word.term.enumerated().map { index, char in makeSlot(at: index, char: char) }
    }
    
    var inputText: String = "" {
        didSet { handleInputChange() }
    }

    init(words: [GameWord], onCompleted: @escaping () -> Void, onClose: @escaping () -> Void) {
        self.words = words
        self.totalWords = words.count
        self.onCompleted = onCompleted
        self.onClose = onClose
    }

    func load() {
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

    /// 입력값을 영문자·최대 길이·소문자로 정규화하고, 복습 라운드 힌트 글자를 보호한다.
    /// 정규화 후 단어 길이와 일치하면 validateAnswer()를 호출한다.
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

    /// 현재 inputText와 정답을 비교해 정답/오답 상태로 전환하고, 다음 단어로 자동 진행한다.
    /// 오답 시 복습 목록에 단어를 추가한다 (복습 라운드 중에는 추가하지 않는다).
    private func validateAnswer() {
        guard viewState == .active, let word = currentWord else { return }

        if isCorrectAnswer(for: word) {
            viewState = .correct
            
            advanceTask = Task {
                try? await Task.sleep(for: .seconds(0.5))
                showWord(at: wordIndex + 1)
            }
        } else {
            viewState = .revealing
            
            if shouldAddToReview(word) {
                incorrectWordIDs.insert(word.id)
                reviewWords.append(word)
            }
            
            advanceTask = Task {
                try? await Task.sleep(for: .seconds(1))
                showWord(at: wordIndex + 1)
            }
        }
    }

    /// 지정 인덱스의 단어를 표시한다. 라운드 종료 시 handleRoundEnd()를 호출한다.
    private func showWord(at index: Int) {
        let currentWords = isReviewRound ? reviewWords : words
        guard index < currentWords.count else {
            handleRoundEnd()
            return
        }

        let word = currentWords[index]
        resetInput(for: word)
        
        wordIndex = index
        currentWord = word
        viewState = .active
    }
    
    private func isCorrectAnswer(for word: GameWord) -> Bool {
        inputText == word.term.lowercased()
    }

    /// 메인 라운드에서 처음 틀린 단어인지 확인한다.
    private func shouldAddToReview(_ word: GameWord) -> Bool {
        !isReviewRound && !incorrectWordIDs.contains(word.id)
    }

    /// 복습 라운드면 첫 글자를 힌트로 채우고, 아니면 빈 문자열로 초기화한다.
    private func resetInput(for word: GameWord) {
        if isReviewRound, let firstChar = word.term.first {
            inputText = String(firstChar).lowercased()
        } else {
            inputText = ""
        }
    }

    /// 메인 라운드 종료 시 오답이 있으면 복습 라운드를 시작하고, 없으면 완료 처리한다.
    private func handleRoundEnd() {
        if !isReviewRound && !reviewWords.isEmpty {
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
    }

    /// 인덱스와 현재 inputText를 기반으로 슬롯 상태를 결정한다.
    /// 복습 라운드의 첫 번째 슬롯은 항상 힌트로 반환한다.
    private func makeSlot(at index: Int, char: Character) -> SlotState {
        // 복습 라운드 첫 번째 슬롯: 힌트 글자 고정
        guard !isReviewRound || index != 0 else {
            return .hint(char.lowercased().first ?? char)
        }
        // 이미 입력된 슬롯
        guard index >= inputText.count else {
            let inputChar = inputText[inputText.index(inputText.startIndex, offsetBy: index)]
            return .filled(inputChar)
        }
        // 현재 커서 위치
        guard index > inputText.count else {
            return .cursor
        }
        // 아직 입력되지 않은 슬롯
        return .empty
    }
}
