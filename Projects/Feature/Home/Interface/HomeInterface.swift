import Foundation

public enum SessionProgressStatus: String {
    case completed
    case notStarted = "not_started"
}

public struct SessionProgress: Equatable, Identifiable {
    public let id: String
    public let sessionNumber: Int
    public let totalWords: Int
    public let status: SessionProgressStatus
    public let lastStudiedAt: Date?
    public let accuracy: Double?
    public let wordsCompleted: Int

    public init(
        id: String,
        sessionNumber: Int,
        totalWords: Int,
        status: SessionProgressStatus,
        lastStudiedAt: Date?,
        accuracy: Double?,
        wordsCompleted: Int
    ) {
        self.id = id
        self.sessionNumber = sessionNumber
        self.totalWords = totalWords
        self.status = status
        self.lastStudiedAt = lastStudiedAt
        self.accuracy = accuracy
        self.wordsCompleted = wordsCompleted
    }
}

public struct LevelSummary: Equatable, Identifiable {
    public let id: String
    public let level: Int
    public let name: String
    public let difficulty: String
    public let totalSessions: Int
    public let completedSessions: Int
    public let sessions: [SessionProgress]

    public init(
        id: String,
        level: Int,
        name: String,
        difficulty: String,
        totalSessions: Int,
        completedSessions: Int,
        sessions: [SessionProgress]
    ) {
        self.id = id
        self.level = level
        self.name = name
        self.difficulty = difficulty
        self.totalSessions = totalSessions
        self.completedSessions = completedSessions
        self.sessions = sessions
    }
}

public struct VocabularyLibrary: Equatable {
    public let levels: [LevelSummary]

    public init(levels: [LevelSummary]) {
        self.levels = levels
    }
}

public protocol HomeRepository {
    func fetchVocabularyLibrary() async throws -> VocabularyLibrary
}
