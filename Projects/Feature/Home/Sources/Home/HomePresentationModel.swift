import Foundation

struct HomePresentationModel: Equatable {
    let streakDays: Int
    let levels: [LevelCardPresentationModel]
}

struct LevelCardPresentationModel: Equatable, Identifiable {
    let id: String
    let level: Int
    let levelBadgeColor: LevelBadgeColor
    let name: String
    let difficulty: String
    let completedSessions: Int
    let totalSessions: Int
    let progressRatio: Double
    let sessions: [SessionRowPresentationModel]
}

struct SessionRowPresentationModel: Equatable, Identifiable {
    let id: Int
    let sessionNumber: Int
    let accuracyPercent: Int?
    let icon: SessionIconKind
}

enum SessionIconKind: Equatable {
    case completedHigh
    case completedLow
    case notStarted
}

enum LevelBadgeColor: Equatable {
    case level1
    case level2
    case level3
    case level4
    case unknown
}
