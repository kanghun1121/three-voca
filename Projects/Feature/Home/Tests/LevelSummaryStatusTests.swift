import XCTest

@testable import FeatureHome
import DomainInterface

final class LevelSummaryStatusTests: XCTestCase {
    func test_completedSessions가_0이면_notStarted다() {
        let level = makeLevel(completedSessions: 0, totalSessions: 10)

        XCTAssertEqual(level.status, .notStarted)
    }

    func test_completedSessions가_totalSessions보다_작으면_active다() {
        let level = makeLevel(completedSessions: 3, totalSessions: 10)

        XCTAssertEqual(level.status, .active)
    }

    func test_completedSessions가_totalSessions와_같으면_completed다() {
        let level = makeLevel(completedSessions: 10, totalSessions: 10)

        XCTAssertEqual(level.status, .completed)
    }

    func test_totalSessions가_0이고_completedSessions도_0이면_notStarted이며_progressRatio는_0이다() {
        let level = makeLevel(completedSessions: 0, totalSessions: 0)

        XCTAssertEqual(level.status, .notStarted)
        XCTAssertEqual(level.progressRatio, 0)
    }

    func test_progressRatio는_completedSessions_나누기_totalSessions다() {
        let level = makeLevel(completedSessions: 3, totalSessions: 10)

        XCTAssertEqual(level.progressRatio, 0.3, accuracy: 0.0001)
    }
}

private func makeLevel(completedSessions: Int, totalSessions: Int) -> LevelSummary {
    LevelSummary(
        id: "level_1",
        level: 1,
        name: "Level 1",
        difficulty: "A1",
        totalSessions: totalSessions,
        completedSessions: completedSessions,
        sessions: []
    )
}
