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

// MARK: - Preview Fixture

public extension VocabularyLibrary {
    static let previewFixture: VocabularyLibrary = {
        let level1Completed: [SessionProgress] = [
            SessionProgress(
                id: "session_l1_s1",
                sessionNumber: 1,
                totalWords: 20,
                status: .completed,
                lastStudiedAt: iso.date(from: "2026-05-03T14:20:00Z"),
                accuracy: 0.92,
                wordsCompleted: 20
            ),
            SessionProgress(
                id: "session_l1_s2",
                sessionNumber: 2,
                totalWords: 20,
                status: .completed,
                lastStudiedAt: iso.date(from: "2026-05-09T10:15:00Z"),
                accuracy: 0.87,
                wordsCompleted: 20
            ),
            SessionProgress(
                id: "session_l1_s3",
                sessionNumber: 3,
                totalWords: 20,
                status: .completed,
                lastStudiedAt: iso.date(from: "2026-05-06T20:45:00Z"),
                accuracy: 0.58,
                wordsCompleted: 20
            ),
            SessionProgress(
                id: "session_l1_s4",
                sessionNumber: 4,
                totalWords: 20,
                status: .completed,
                lastStudiedAt: iso.date(from: "2026-05-08T08:10:00Z"),
                accuracy: 0.88,
                wordsCompleted: 20
            ),
        ]
        let level1Sessions: [SessionProgress] = level1Completed + (5...42).map { i in
            SessionProgress(
                id: "session_l1_s\(i)",
                sessionNumber: i,
                totalWords: i == 42 ? 5 : 20,
                status: .notStarted,
                lastStudiedAt: nil,
                accuracy: nil,
                wordsCompleted: 0
            )
        }

        return VocabularyLibrary(levels: [
            LevelSummary(
                id: "level_1",
                level: 1,
                name: "초등 기초",
                difficulty: "A1",
                totalSessions: 42,
                completedSessions: 4,
                sessions: level1Sessions
            ),
            LevelSummary(
                id: "level_2",
                level: 2,
                name: "초등 심화",
                difficulty: "A2",
                totalSessions: 39,
                completedSessions: 0,
                sessions: (1...39).map { i in
                    SessionProgress(
                        id: "session_l2_s\(i)",
                        sessionNumber: i,
                        totalWords: i == 39 ? 12 : 20,
                        status: .notStarted,
                        lastStudiedAt: nil,
                        accuracy: nil,
                        wordsCompleted: 0
                    )
                }
            ),
            LevelSummary(
                id: "level_3",
                level: 3,
                name: "중등 ~ 수능",
                difficulty: "B1-B2",
                totalSessions: 99,
                completedSessions: 0,
                sessions: (1...99).map { i in
                    SessionProgress(
                        id: "session_l3_s\(i)",
                        sessionNumber: i,
                        totalWords: i == 99 ? 7 : 20,
                        status: .notStarted,
                        lastStudiedAt: nil,
                        accuracy: nil,
                        wordsCompleted: 0
                    )
                }
            ),
            LevelSummary(
                id: "level_4",
                level: 4,
                name: "수능 심화",
                difficulty: "C1",
                totalSessions: 64,
                completedSessions: 0,
                sessions: (1...64).map { i in
                    SessionProgress(
                        id: "session_l4_s\(i)",
                        sessionNumber: i,
                        totalWords: i == 64 ? 11 : 20,
                        status: .notStarted,
                        lastStudiedAt: nil,
                        accuracy: nil,
                        wordsCompleted: 0
                    )
                }
            ),
        ])
    }()

    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
}
