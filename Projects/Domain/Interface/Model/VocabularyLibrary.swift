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
        // "오늘" 기준 상대 날짜로 구성 — 실행 시점과 무관하게 항상 다양한 캘린더 케이스(당일 3건 캡 경계,
        // 다른 날 1건, 오늘은 0건)가 현재 달 화면에서 바로 보이도록 한다.
        let level1Completed: [SessionProgress] = [
            SessionProgress(
                id: "1",
                sessionNumber: 1,
                totalWords: 20,
                status: .completed,
                lastStudiedAt: daysAgo(5, hour: 9, minute: 20),
                accuracy: 0.92,
                wordsCompleted: 20
            ),
            SessionProgress(
                id: "2",
                sessionNumber: 2,
                totalWords: 20,
                status: .completed,
                lastStudiedAt: daysAgo(5, hour: 14, minute: 5),
                accuracy: 0.87,
                wordsCompleted: 20
            ),
            SessionProgress(
                id: "3",
                sessionNumber: 3,
                totalWords: 20,
                status: .completed,
                lastStudiedAt: daysAgo(5, hour: 21, minute: 40),
                accuracy: 0.58,
                wordsCompleted: 20
            ),
            SessionProgress(
                id: "4",
                sessionNumber: 4,
                totalWords: 20,
                status: .completed,
                lastStudiedAt: daysAgo(2, hour: 19, minute: 10),
                accuracy: 0.88,
                wordsCompleted: 20
            ),
        ]
        let level1Sessions: [SessionProgress] = level1Completed + (5...42).map { i in
            SessionProgress(
                id: "\(i)",
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
                name: "씨앗",
                difficulty: "A1",
                totalSessions: 42,
                completedSessions: 4,
                sessions: level1Sessions
            ),
            LevelSummary(
                id: "level_2",
                level: 2,
                name: "새싹",
                difficulty: "A2",
                totalSessions: 39,
                completedSessions: 0,
                sessions: (1...39).map { i in
                    SessionProgress(
                        id: "\(42 + i)",
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
                name: "줄기",
                difficulty: "B1",
                totalSessions: 99,
                completedSessions: 0,
                sessions: (1...99).map { i in
                    SessionProgress(
                        id: "\(81 + i)",
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
                name: "가지",
                difficulty: "B2",
                totalSessions: 64,
                completedSessions: 0,
                sessions: (1...64).map { i in
                    SessionProgress(
                        id: "\(180 + i)",
                        sessionNumber: i,
                        totalWords: i == 64 ? 11 : 20,
                        status: .notStarted,
                        lastStudiedAt: nil,
                        accuracy: nil,
                        wordsCompleted: 0
                    )
                }
            ),
            LevelSummary(
                id: "level_5",
                level: 5,
                name: "꽃",
                difficulty: "C1",
                totalSessions: 50,
                completedSessions: 0,
                sessions: (1...50).map { i in
                    SessionProgress(
                        id: "\(244 + i)",
                        sessionNumber: i,
                        totalWords: i == 50 ? 15 : 20,
                        status: .notStarted,
                        lastStudiedAt: nil,
                        accuracy: nil,
                        wordsCompleted: 0
                    )
                }
            ),
            LevelSummary(
                id: "level_6",
                level: 6,
                name: "나무",
                difficulty: "C2",
                totalSessions: 30,
                completedSessions: 0,
                sessions: (1...30).map { i in
                    SessionProgress(
                        id: "\(294 + i)",
                        sessionNumber: i,
                        totalWords: i == 30 ? 18 : 20,
                        status: .notStarted,
                        lastStudiedAt: nil,
                        accuracy: nil,
                        wordsCompleted: 0
                    )
                }
            ),
        ])
    }()

    private static func daysAgo(_ days: Int, hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let base = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
    }
}
