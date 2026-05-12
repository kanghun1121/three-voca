import Foundation

struct HomeViewState: Equatable {
    let streakDays: Int
    let levels: [LevelCardViewState]
}

struct LevelCardViewState: Equatable, Identifiable {
    let id: String
    let levelBadgeText: String
    let levelBadgeColor: LevelBadgeColor
    let name: String
    let subtitle: String
    let progressRatio: Double
    let sessions: [SessionRowViewState]
}

struct SessionRowViewState: Equatable, Identifiable {
    let id: Int
    let title: String
    let subtitle: String
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
