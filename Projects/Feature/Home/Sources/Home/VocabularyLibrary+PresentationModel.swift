import Foundation

import DomainInterface

extension VocabularyLibrary {
    func toHomePresentationModel() -> HomePresentationModel {
        HomePresentationModel(levels: levels.map { $0.toLevelCardPresentationModel() })
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
