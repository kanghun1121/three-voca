import Foundation

import DomainInterface
import Dependencies

@Observable
@MainActor
public final class RecognitionViewModel {

    public enum Phase: Equatable {
        case loading
        case active
        case revealing
        case completed
        case error(String)
    }

    // MARK: - Public State

    public private(set) var phase: Phase = .loading
    public private(set) var currentWord: GameWord?
    public private(set) var countdown: Int = 5
    public private(set) var wordIndex: Int = 0
    public private(set) var totalWords: Int = 0

    // MARK: - Private

    @ObservationIgnored @Dependency(\.sessionClient) private var sessionClient
    @ObservationIgnored @Dependency(\.audioClient) private var audioClient
    @ObservationIgnored @Dependency(\.audioPlayerClient) private var audioPlayerClient

    private let sessionID: String
    private var words: [GameWord] = []
    private var countdownTask: Task<Void, Never>?
    private var revealTask: Task<Void, Never>?

    // MARK: - Init

    public init(sessionID: String) {
        self.sessionID = sessionID
    }

    // MARK: - Lifecycle

    public func start() async {
        do {
            let session = try await sessionClient.fetchSessionDetail(sessionID)
            words = session.words.map { GameWord(from: $0) }
            totalWords = words.count
            if words.isEmpty {
                phase = .completed
                return
            }
            beginWord(at: 0)
        } catch {
            phase = .error("단어를 불러오지 못했습니다.")
        }
    }

    public func dismiss() {
        countdownTask?.cancel()
        revealTask?.cancel()
        phase = .completed
    }

    // MARK: - 사용자 액션

    public func didTapRemembered() {
        guard case .active = phase else { return }
        countdownTask?.cancel()
        revealAndAdvance()
    }

    public func didTapForgot() {
        guard case .active = phase else { return }
        countdownTask?.cancel()
        revealAndAdvance()
    }

    public func didTapAudio() async {
        guard let word = currentWord else { return }
        guard let url = await audioClient.audioURL(word.term) else { return }
        await audioPlayerClient.play(url)
    }

    // MARK: - 내부 흐름

    private func beginWord(at index: Int) {
        guard index < words.count else {
            phase = .completed
            return
        }
        wordIndex = index
        currentWord = words[index]
        startCountdown()
    }

    private func startCountdown() {
        countdownTask?.cancel()
        countdown = 5
        phase = .active

        countdownTask = Task {
            for remaining in stride(from: 5, through: 0, by: -1) {
                guard !Task.isCancelled else { return }
                countdown = remaining
                if remaining == 0 {
                    revealAndAdvance()
                    return
                }
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func revealAndAdvance() {
        countdownTask?.cancel()
        phase = .revealing
        revealTask?.cancel()
        revealTask = Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            beginWord(at: wordIndex + 1)
        }
    }
}
