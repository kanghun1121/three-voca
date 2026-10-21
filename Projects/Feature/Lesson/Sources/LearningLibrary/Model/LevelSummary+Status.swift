import DomainInterface

extension LevelSummary {
    var status: LevelStatus {
        if completedLessons == 0 {
            .notStarted
        } else if completedLessons >= totalLessons {
            .completed
        } else {
            .active
        }
    }

    var progressRatio: Double {
        totalLessons == 0 ? 0 : Double(completedLessons) / Double(totalLessons)
    }

    /// 레슨이 하나도 없는 단계(오늘은 심화·완성)는 잠긴 것으로 취급한다.
    var isLocked: Bool {
        totalLessons == 0
    }
}
