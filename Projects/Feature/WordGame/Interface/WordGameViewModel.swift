import Foundation

import DomainInterface

@Observable
@MainActor
public final class WordGameViewModel {

    // MARK: - Public State

    public private(set) var currentWordIndex: Int = 0
    public private(set) var currentStage: GameStage = .recognition
    public private(set) var isCompleted: Bool = false

    // 인식 단계
    public private(set) var recognitionCountdown: Int = 5

    // 뜻 단계
    public private(set) var meaningChoices: [String] = []
    public private(set) var selectedMeaningIndex: Int? = nil

    // 스펠링 단계
    public var spellingInput: String = ""

    // 발음 단계
    public private(set) var isMicListening: Bool = false

    // MARK: - Private State

    private let words: [GameWord]
    private var countdownTask: Task<Void, Never>?
    private var micTask: Task<Void, Never>?

    // MARK: - Init

    public init(words: [Session.Word]) {
        self.words = words.map { GameWord(from: $0) }
    }

    // MARK: - Computed

    public var currentWord: GameWord? {
        guard currentWordIndex < words.count else { return nil }
        return words[currentWordIndex]
    }

    public var totalWordCount: Int { words.count }

    // MARK: - Lifecycle

    public func start() {
        currentWordIndex = 0
        currentStage = .recognition
        isCompleted = false
        startRecognitionStage()
    }

    public func dismissGame() {
        countdownTask?.cancel()
        micTask?.cancel()
        isCompleted = true
    }

    // MARK: - 인식 단계

    private func startRecognitionStage() {
        recognitionCountdown = 5
        selectedMeaningIndex = nil
        spellingInput = ""
        isMicListening = false

        countdownTask?.cancel()
        countdownTask = Task {
            for remaining in stride(from: 5, through: 0, by: -1) {
                guard !Task.isCancelled else { return }
                recognitionCountdown = remaining
                if remaining == 0 {
                    recognitionDidTap(remembered: false)
                    return
                }
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    public func recognitionDidTap(remembered: Bool) {
        countdownTask?.cancel()
        advanceStage()
    }

    // MARK: - 뜻 단계

    private func startMeaningStage() {
        guard let word = currentWord else { return }
        let correct = word.primaryMeaning
        let distractors = words
            .filter { $0.id != word.id }
            .map(\.primaryMeaning)
            .shuffled()
            .prefix(3)
        let choices = ([correct] + distractors).shuffled()
        meaningChoices = Array(choices)
        selectedMeaningIndex = nil
    }

    public func meaningDidSelect(index: Int) {
        guard selectedMeaningIndex == nil else { return }
        selectedMeaningIndex = index
        Task {
            try? await Task.sleep(for: .milliseconds(600))
            advanceStage()
        }
    }

    public var correctMeaningIndex: Int? {
        guard let word = currentWord else { return nil }
        return meaningChoices.firstIndex(of: word.primaryMeaning)
    }

    // MARK: - 스펠링 단계

    public func spellingDidConfirm() {
        advanceStage()
    }

    // MARK: - 발음 단계

    public func micDidTap() {
        guard !isMicListening else { return }
        isMicListening = true
        micTask?.cancel()
        micTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            isMicListening = false
            advanceStage()
        }
    }

    // MARK: - 스테이지 전환

    private func advanceStage() {
        switch currentStage {
        case .recognition:
            currentStage = .meaning
            startMeaningStage()
        case .meaning:
            currentStage = .spelling
        case .spelling:
            currentStage = .pronunciation
        case .pronunciation:
            advanceWord()
        }
    }

    private func advanceWord() {
        let nextIndex = currentWordIndex + 1
        if nextIndex >= words.count {
            isCompleted = true
        } else {
            currentWordIndex = nextIndex
            currentStage = .recognition
            startRecognitionStage()
        }
    }
}
