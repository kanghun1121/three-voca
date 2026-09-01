import DomainInterface

extension LevelSummary {
    var status: LevelStatus {
        if completedSessions == 0 {
            return .notStarted
        } else if completedSessions >= totalSessions {
            return .completed
        } else {
            return .active
        }
    }

    var progressRatio: Double {
        totalSessions == 0 ? 0 : Double(completedSessions) / Double(totalSessions)
    }
}
