import Foundation

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
