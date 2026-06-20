import Foundation

struct HomePresentationModel: Equatable {
    let levels: [LevelCardPresentationModel]
}

struct LevelCardPresentationModel: Equatable, Identifiable {
    let id: String
    let level: Int
    let name: String
    let status: LevelStatus
    let completedSessions: Int
    let totalSessions: Int
    let progressRatio: Double
    let sessions: [SessionRowPresentationModel]
}

struct SessionRowPresentationModel: Equatable, Identifiable {
    let id: Int
    let sessionNumber: Int
    let icon: SessionIconKind
}

enum LevelStatus: Equatable {
    case active
    case completed
    case notStarted
}

enum SessionIconKind: Equatable {
    case completedHigh
    case completedLow
    case notStarted

    var isCompleted: Bool { self != .notStarted }
}

enum LevelBadgeColor: Equatable {
    case level1
    case level2
    case level3
    case level4
    case unknown
}
