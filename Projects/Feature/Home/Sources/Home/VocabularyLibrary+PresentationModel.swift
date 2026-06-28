import Foundation

import DomainInterface

extension VocabularyLibrary {
    func toHomePresentationModel(activities: [DailyActivity]) -> HomePresentationModel {
        HomePresentationModel(
            levels: levels.map { $0.toLevelCardPresentationModel() },
            streakDays: activities.streakDays()
        )
    }
}

private extension LevelSummary {
    func toLevelCardPresentationModel() -> LevelCardPresentationModel {
        let status: LevelStatus
        if completedSessions == 0 {
            status = .notStarted
        } else if completedSessions >= totalSessions {
            status = .completed
        } else {
            status = .active
        }
        return LevelCardPresentationModel(
            id: id,
            level: level,
            name: name,
            status: status,
            completedSessions: completedSessions,
            totalSessions: totalSessions,
            progressRatio: totalSessions == 0 ? 0 : Double(completedSessions) / Double(totalSessions),
            sessions: sessions.map { $0.toSessionRowPresentationModel() }
        )
    }
}

private extension SessionProgress {
    func toSessionRowPresentationModel() -> SessionRowPresentationModel {
        SessionRowPresentationModel(
            id: Int(id) ?? 0,
            sessionNumber: sessionNumber,
            icon: status == .completed ? .completedHigh : .notStarted
        )
    }
}

private extension [DailyActivity] {
    func streakDays() -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date.now)
        let studiedDates = Set(self.compactMap { activity -> Date? in
            guard let date = ISO8601DateFormatter.yyyyMMdd.date(from: activity.date) else { return nil }
            return cal.startOfDay(for: date)
        })
        var streak = 0
        var cursor = today
        while studiedDates.contains(cursor) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }
}

private extension ISO8601DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
