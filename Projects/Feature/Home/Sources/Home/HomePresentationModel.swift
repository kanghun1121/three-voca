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
    let status: SessionCellStatus
}

enum LevelStatus: Equatable {
    case active
    case completed
    case notStarted
}

enum SessionCellStatus: Equatable {
    case done
    case current
    case todo
}
