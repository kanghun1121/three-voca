import Foundation

struct HomeViewState: Equatable {
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
    let id: String
    let title: String
    let trailingText: String
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
    case unknown
}
