import Foundation

import DomainInterface
import Dependencies
import SwiftUINavigation

@Observable
@MainActor
public final class RecognitionViewModel {

    enum ViewState: Equatable {
        case loading
        case active
        case revealing
        case completed
        case error(String)
    }

    enum AlertAction {
        case confirmSave
        case confirmDiscard
    }

    @CasePathable
    enum Destination {
        case alert(AlertState<AlertAction>)
    }

    private(set) var viewState: ViewState = .loading
    private(set) var currentWord: GameWord?
    private(set) var countdown: Int = 5
    private(set) var ringProgress: Double = 1.0
    private(set) var wordIndex: Int = 0
    private(set) var totalWords: Int = 0
    var destination: Destination?
    var dismiss = false

    @ObservationIgnored @Dependency(\.sessionClient) private var sessionClient
    @ObservationIgnored @Dependency(\.audioClient) private var audioClient
    @ObservationIgnored @Dependency(\.audioPlayerClient) private var audioPlayerClient

    private let sessionID: String
    private var words: [GameWord] = []
    private var countdownTask: Task<Void, Never>?
    private var revealTask: Task<Void, Never>?
    private var audioTask: Task<Void, Never>?
    private let totalCountdown: Double = 5.0
    private var remainingSeconds: Double = 5.0

    public init(sessionID: String) {
        self.sessionID = sessionID
    }

    func load() async {
        do {
            let session = try await sessionClient.fetchSessionDetail(sessionID)
            words = session.words.map { GameWord(from: $0) }
            totalWords = words.count
            if words.isEmpty {
                viewState = .completed
                return
            }
            showWord(at: 0)
        } catch {
            viewState = .error("단어를 불러오지 못했습니다.")
        }
    }

    // X 버튼 — 남은 시간을 저장하고 타이머 Task를 즉시 cancel한 뒤 알럿 표시
    func closeButtonTapped() {
        remainingSeconds = ringProgress * totalCountdown
        countdownTask?.cancel()
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

    // 완료/에러 화면 닫기 버튼
    func doneButtonTapped() {
        dismiss = true
    }

    func alertButtonTapped(_ action: AlertAction?) {
        switch action {
        case .confirmSave, .confirmDiscard:
            revealTask?.cancel()
            audioTask?.cancel()
            dismiss = true
        case .none:
            startCountdown(remaining: remainingSeconds)
        }
    }

    func rememberedButtonTapped() {
        guard case .active = viewState else { return }
        countdownTask?.cancel()
        revealAndAdvance()
    }

    func forgotButtonTapped() {
        guard case .active = viewState else { return }
        countdownTask?.cancel()
        revealAndAdvance()
    }

    private func showWord(at index: Int) {
        guard index < words.count else {
            viewState = .completed
            return
        }

        let word = setCurrentWord(at: index)

        audioTask?.cancel()
        audioTask = Task {
            guard let url = await audioClient.audioURL(word.term) else { return }
            guard !Task.isCancelled else { return }
            await audioPlayerClient.play(url)
        }

        startCountdown()
    }

    private func setCurrentWord(at index: Int) -> GameWord {
        let word = words[index]
        wordIndex = index
        currentWord = word
        return word
    }

    private func startCountdown(remaining: Double = 5.0) {
        countdownTask?.cancel()
        ringProgress = remaining / totalCountdown
        countdown = Int(ceil(remaining))
        viewState = .active

        countdownTask = Task {
            let startDate = Date.now

            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(10))

                let left = remaining - Date.now.timeIntervalSince(startDate)
                updateProgress(timeLeft: max(0, left))
                if left <= 0 { break }
            }

            guard !Task.isCancelled else { return }
            revealAndAdvance()
        }
    }

    private func updateProgress(timeLeft: Double) {
        ringProgress = timeLeft / totalCountdown
        countdown = Int(ceil(timeLeft))
    }

    private func revealAndAdvance() {
        countdownTask?.cancel()
        viewState = .revealing
        revealTask?.cancel()
        revealTask = Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            showWord(at: wordIndex + 1)
        }
    }
}
