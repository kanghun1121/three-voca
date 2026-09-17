import XCTest

@testable import FeatureLesson
import DomainInterface

final class SessionStatusTests: XCTestCase {
    func test_빈배열이면_빈배열을_반환한다() {
        let lessons: [LessonProgress] = []

        XCTAssertEqual(lessons.sessionStatuses, [])
    }

    func test_완료된세션은_completed이고_완료되지않은_첫세션은_active이며_나머지는_upcoming이다() {
        let lessons = [
            makeLesson(status: .completed),
            makeLesson(status: .notStarted),
            makeLesson(status: .notStarted)
        ]

        XCTAssertEqual(lessons.sessionStatuses, [.completed, .active, .upcoming])
    }

    func test_모두_완료된세션이면_active없이_전부_completed다() {
        let lessons = [
            makeLesson(status: .completed),
            makeLesson(status: .completed)
        ]

        XCTAssertEqual(lessons.sessionStatuses, [.completed, .completed])
    }

    func test_단일_미완료세션은_active다() {
        let lessons = [makeLesson(status: .notStarted)]

        XCTAssertEqual(lessons.sessionStatuses, [.active])
    }
}

private func makeLesson(status: LessonProgressStatus) -> LessonProgress {
    LessonProgress(
        id: "1",
        lessonNumber: 1,
        totalWords: 20,
        status: status,
        lastStudiedAt: nil,
        accuracy: nil,
        wordsCompleted: 0
    )
}
