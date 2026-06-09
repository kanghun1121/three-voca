import Foundation

import SwiftUINavigation

@Observable
@MainActor
public final class SpellingViewModel {

    enum ViewState: Equatable {
        case active
        case correct
        case incorrect
        case completed
    }

    enum SlotState: Equatable {
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
    var inputText: String = "" {
        didSet {
            guard viewState == .active else { return }
            let limit = currentWord?.term.count ?? 0
            let filtered = String(inputText.filter { $0.isLetter }.prefix(limit).lowercased())
            guard inputText == filtered else {
                inputText = filtered
                return
            }
            if inputText.count == limit {
                validateAnswer()
            }
        }
    }
    var destination: Destination?

    private let words: [GameWord]
    private let onCompleted: () -> Void
    private let onClose: () -> Void

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

    private var isConfirmEnabled: Bool {
        guard let word = currentWord else { return false }
        return inputText.count == word.term.count
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
            viewState = .incorrect
            advanceTask = Task {
                try? await Task.sleep(for: .milliseconds(800))
                guard !Task.isCancelled else { return }
                inputText = ""
                viewState = .active
            }
        }
    }

    private func showWord(at index: Int) {
        guard index < words.count else {
            viewState = .completed
            advanceTask = Task {
                try? await Task.sleep(for: .milliseconds(800))
                guard !Task.isCancelled else { return }
                onCompleted()
            }
            return
        }
        inputText = ""
        wordIndex = index
        currentWord = words[index]
        viewState = .active
    }
}
