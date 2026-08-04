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
    /// 오늘 기준 최근 며칠에 걸쳐 학습 강도 1~4단계를 모두 보여주는 데모 픽스처.
    static let previewFixture: [DailyActivity] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        func activity(daysAgo: Int, sessionsCount: Int) -> DailyActivity? {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            return DailyActivity(date: formatter.string(from: date), sessionsCount: sessionsCount)
        }

        return [
            activity(daysAgo: 8, sessionsCount: 1),
            activity(daysAgo: 6, sessionsCount: 2),
            activity(daysAgo: 4, sessionsCount: 3),
            activity(daysAgo: 2, sessionsCount: 4),
        ].compactMap { $0 }
    }()
}
