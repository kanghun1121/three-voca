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
    private(set) var inputLetters: [Character] = []
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
            if index < inputLetters.count {
                return .filled(inputLetters[index])
            } else if index == inputLetters.count {
                return .cursor
            } else {
                return .empty
            }
        }
    }

    var isConfirmEnabled: Bool {
        guard let word = currentWord else { return false }
        return inputLetters.count == word.term.count
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

    func letterTapped(_ letter: Character) {
        guard case .active = viewState,
              let word = currentWord,
              inputLetters.count < word.term.count else { return }

        inputLetters.append(letter)

        if inputLetters.count == word.term.count {
            validateAnswer()
        }
    }

    func deleteTapped() {
        guard case .active = viewState, !inputLetters.isEmpty else { return }
        inputLetters.removeLast()
    }

    func confirmTapped() {
        guard case .active = viewState, isConfirmEnabled else { return }
        validateAnswer()
    }

    private func validateAnswer() {
        guard let word = currentWord else { return }
        let input = String(inputLetters).lowercased()
        let answer = word.term.lowercased()

        if input == answer {
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
                inputLetters = []
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
        inputLetters = []
        wordIndex = index
        currentWord = words[index]
        viewState = .active
    }
}
