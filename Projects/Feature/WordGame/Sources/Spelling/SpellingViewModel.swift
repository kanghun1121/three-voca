import Foundation

import DomainInterface

import Dependencies
import SwiftUINavigation

@Observable
@MainActor
public final class SpellingViewModel {
    enum ViewState: Equatable {
        case active
        case correct
        case incorrect
        case revealing
    }

    enum AlertAction {
        case confirmDiscard
    }

    @CasePathable
    enum Destination {
        case alert(AlertState<AlertAction>)
    }

    var destination: Destination?

    private(set) var viewState: ViewState = .active
    private(set) var currentWord: Lesson.Word?
    private(set) var wordIndex: Int = 0
    private(set) var totalWords: Int = 0
    private let words: [Lesson.Word]
    private let onCompleted: () -> Void
    private let onClose: () -> Void
    private var reviewTracker = ReviewRoundTracker()
    var isReviewRound: Bool { reviewTracker.isReviewRound }
    private(set) var advanceTask: Task<Void, Never>?
    var inputText: String = "" {
        didSet { handleInputChange() }
    }

    @ObservationIgnored @Dependency(\.continuousClock) private var clock
    @ObservationIgnored @Dependency(\.soundClient) private var soundClient

    init(
        words: [Lesson.Word],
        onCompleted: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
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

    func skipButtonTapped() {
        guard viewState == .active, let word = currentWord else { return }
        soundClient.playWrong()
        viewState = .revealing
        reviewTracker.registerIncorrect(word)
        advanceTask = Task { [weak self] in
            guard let self else { return }
            try? await self.clock.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            showWord(at: wordIndex + 1)
        }
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

    /// 입력값을 영문자·띄어쓰기(맨 앞·연속 제외)·최대 길이·소문자로 정규화하고, 복습 라운드 힌트 글자를 보호한다.
    /// 정답 확인은 입력으로 자동 실행하지 않고 submitButtonTapped()에서만 한다.
    private func handleInputChange() {
        guard viewState == .active else { return }
        let limit = currentWord?.term.count ?? 0
        var filtered = ""
        for character in inputText.lowercased() {
            if character.isLetter {
                filtered.append(character)
            } else if character == " ", let last = filtered.last, last != " " {
                filtered.append(character)
            }
        }
        filtered = String(filtered.prefix(limit))

        // 복습 라운드: 첫 글자 힌트는 입력이 있을 때만 앞에 고정한다. 전체 지우기로 비우는 것은 허용한다.
        if reviewTracker.isReviewRound, !filtered.isEmpty, let firstChar = currentWord?.term.first {
            let hint = String(firstChar).lowercased()
            if !filtered.hasPrefix(hint) { filtered = hint }
        }

        if inputText != filtered { inputText = filtered }
    }

    var canSubmit: Bool {
        viewState == .active && !inputText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func submitButtonTapped() {
        guard canSubmit else { return }
        validateAnswer()
    }

    /// 현재 inputText와 정답을 비교해 정답/오답 상태로 전환하고, 다음 단어로 자동 진행한다.
    /// 오답 시 복습 목록에 단어를 추가한다 (복습 라운드 중에는 추가하지 않는다).
    private func validateAnswer() {
        guard viewState == .active, let word = currentWord else { return }

        if isCorrectAnswer(for: word) {
            soundClient.playCorrect()
            viewState = .correct

            advanceTask = Task { [weak self] in
                guard let self else { return }
                try? await self.clock.sleep(for: .seconds(0.5))
                guard !Task.isCancelled else { return }
                showWord(at: wordIndex + 1)
            }
        } else {
            soundClient.playWrong()
            viewState = .revealing

            reviewTracker.registerIncorrect(word)

            advanceTask = Task { [weak self] in
                guard let self else { return }
                try? await self.clock.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                showWord(at: wordIndex + 1)
            }
        }
    }

    /// 지정 인덱스의 단어를 표시한다. 라운드 종료 시 handleRoundEnd()를 호출한다.
    private func showWord(at index: Int) {
        let currentWords = reviewTracker.currentWords(mainWords: words)
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

    private func isCorrectAnswer(for word: Lesson.Word) -> Bool {
        inputText.trimmingCharacters(in: .whitespaces) == word.term.lowercased()
    }

    /// 복습 라운드면 첫 글자를 힌트로 채우고, 아니면 빈 문자열로 초기화한다.
    private func resetInput(for word: Lesson.Word) {
        if reviewTracker.isReviewRound, let firstChar = word.term.first {
            inputText = String(firstChar).lowercased()
        } else {
            inputText = ""
        }
    }

    /// 메인 라운드 종료 시 오답이 있으면 복습 라운드를 시작하고, 없으면 완료 처리한다.
    private func handleRoundEnd() {
        if reviewTracker.startReviewRoundIfNeeded() {
            totalWords = reviewTracker.currentWords(mainWords: words).count
            showWord(at: 0)
        } else {
            onCompleted()
        }
    }
}
