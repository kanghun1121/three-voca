import Foundation

import DomainInterface

extension VocabularyLibrary {
    func toHomePresentationModel() -> HomePresentationModel {
        HomePresentationModel(
            levels: levels.map { $0.toLevelCardPresentationModel() }
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
            sessions: sessions.toSessionRowPresentationModels()
        )
    }
}

private extension [SessionProgress] {
    /// 완료된 세션은 done, 완료되지 않은 첫 세션은 current, 나머지는 todo로 표시.
    func toSessionRowPresentationModels() -> [SessionRowPresentationModel] {
        var currentAssigned = false
        return map { session in
            let status: SessionCellStatus
            if session.status == .completed {
                status = .done
            } else if !currentAssigned {
                status = .current
                currentAssigned = true
            } else {
                status = .todo
            }
            return SessionRowPresentationModel(
                id: Int(session.id) ?? 0,
                sessionNumber: session.sessionNumber,
                status: status
            )
        }
    }
}
