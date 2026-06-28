import Foundation

public struct DailyActivity: Equatable, Sendable {
    public let date: String
    public let sessionsCount: Int

    public init(date: String, sessionsCount: Int) {
        self.date = date
        self.sessionsCount = sessionsCount
    }
}

// MARK: - Preview Fixture

public extension DailyActivity {
    static let previewFixture: [DailyActivity] = [
        DailyActivity(date: "2026-06-10", sessionsCount: 2),
        DailyActivity(date: "2026-06-11", sessionsCount: 1),
        DailyActivity(date: "2026-06-13", sessionsCount: 3),
        DailyActivity(date: "2026-06-27", sessionsCount: 3),
    ]
}
