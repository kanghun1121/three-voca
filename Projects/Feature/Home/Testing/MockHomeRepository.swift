import FeatureHomeInterface
import Foundation

public final class MockHomeRepository: HomeRepository {
    public init() {}

    public func fetchVocabularyLibrary() async throws -> VocabularyLibrary {
        try await Task.sleep(for: .milliseconds(Int.random(in: 300...500)))
        return MockHomeRepository.sampleVocabularyLibrary
    }

    // MARK: - Sample Fixtures

    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static func date(_ string: String) -> Date? {
        iso.date(from: string)
    }

    private static let level1Sessions: [SessionProgress] = [
        SessionProgress(
            id: "session_l1_s1",
            sessionNumber: 1,
            totalWords: 15,
            status: .completed,
            lastStudiedAt: date("2026-05-03T14:20:00Z"),
            accuracy: 0.92,
            wordsCompleted: 15
        ),
        SessionProgress(
            id: "session_l1_s2",
            sessionNumber: 2,
            totalWords: 15,
            status: .completed,
            lastStudiedAt: date("2026-05-09T10:15:00Z"),
            accuracy: 0.87,
            wordsCompleted: 15
        ),
        SessionProgress(
            id: "session_l1_s3",
            sessionNumber: 3,
            totalWords: 15,
            status: .completed,
            lastStudiedAt: date("2026-05-06T20:45:00Z"),
            accuracy: 0.58,
            wordsCompleted: 15
        ),
        SessionProgress(
            id: "session_l1_s4",
            sessionNumber: 4,
            totalWords: 15,
            status: .completed,
            lastStudiedAt: date("2026-05-08T08:10:00Z"),
            accuracy: 0.88,
            wordsCompleted: 15
        ),
        SessionProgress(
            id: "session_l1_s5",
            sessionNumber: 5,
            totalWords: 15,
            status: .notStarted,
            lastStudiedAt: nil,
            accuracy: nil,
            wordsCompleted: 0
        ),
        SessionProgress(
            id: "session_l1_s6",
            sessionNumber: 6,
            totalWords: 15,
            status: .notStarted,
            lastStudiedAt: nil,
            accuracy: nil,
            wordsCompleted: 0
        ),
        SessionProgress(
            id: "session_l1_s7",
            sessionNumber: 7,
            totalWords: 15,
            status: .notStarted,
            lastStudiedAt: nil,
            accuracy: nil,
            wordsCompleted: 0
        ),
        SessionProgress(
            id: "session_l1_s8",
            sessionNumber: 8,
            totalWords: 15,
            status: .notStarted,
            lastStudiedAt: nil,
            accuracy: nil,
            wordsCompleted: 0
        ),
        SessionProgress(
            id: "session_l1_s9",
            sessionNumber: 9,
            totalWords: 15,
            status: .notStarted,
            lastStudiedAt: nil,
            accuracy: nil,
            wordsCompleted: 0
        ),
        SessionProgress(
            id: "session_l1_s10",
            sessionNumber: 10,
            totalWords: 15,
            status: .notStarted,
            lastStudiedAt: nil,
            accuracy: nil,
            wordsCompleted: 0
        ),
        SessionProgress(
            id: "session_l1_s11",
            sessionNumber: 11,
            totalWords: 15,
            status: .notStarted,
            lastStudiedAt: nil,
            accuracy: nil,
            wordsCompleted: 0
        ),
        SessionProgress(
            id: "session_l1_s12",
            sessionNumber: 12,
            totalWords: 15,
            status: .notStarted,
            lastStudiedAt: nil,
            accuracy: nil,
            wordsCompleted: 0
        ),
        SessionProgress(
            id: "session_l1_s13",
            sessionNumber: 13,
            totalWords: 15,
            status: .notStarted,
            lastStudiedAt: nil,
            accuracy: nil,
            wordsCompleted: 0
        ),
    ]

    public static let sampleVocabularyLibrary = VocabularyLibrary(levels: [
        LevelSummary(
            id: "level_1",
            level: 1,
            name: "초등 기초",
            difficulty: "A1-A2",
            totalSessions: 13,
            completedSessions: 4,
            sessions: level1Sessions
        ),
        LevelSummary(
            id: "level_2",
            level: 2,
            name: "초등 심화",
            difficulty: "B1",
            totalSessions: 17,
            completedSessions: 0,
            sessions: (1...17).map { i in
                SessionProgress(
                    id: "session_l2_s\(i)",
                    sessionNumber: i,
                    totalWords: 15,
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
            name: "중등 기본",
            difficulty: "B2",
            totalSessions: 40,
            completedSessions: 0,
            sessions: (1...40).map { i in
                SessionProgress(
                    id: "session_l3_s\(i)",
                    sessionNumber: i,
                    totalWords: 15,
                    status: .notStarted,
                    lastStudiedAt: nil,
                    accuracy: nil,
                    wordsCompleted: 0
                )
            }
        ),
    ])
}
