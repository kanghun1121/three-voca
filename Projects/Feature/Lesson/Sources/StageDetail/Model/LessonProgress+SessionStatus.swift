import DomainInterface

extension [LessonProgress] {
    /// 완료된 세션은 completed, 완료되지 않은 첫 세션은 active, 나머지는 upcoming으로 표시.
    var sessionStatuses: [SessionStatus] {
        var currentAssigned = false
        return map { lesson in
            if lesson.status == .completed {
                return .completed
            } else if !currentAssigned {
                currentAssigned = true
                return .active
            } else {
                return .upcoming
            }
        }
    }
}
