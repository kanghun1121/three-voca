import XCTest

@testable import Data

final class LearningHistoryLocalDataSourceTests: XCTestCase {
    func test_처음_완료하면_studyCount_1로_새_행이_생긴다() async throws {
        let db = LocalDatabaseTestContext()
        let date = Date()

        try await db.run {
            try await LearningHistoryLocalDataSource.liveValue.recordCompletion(1, date)
        }

        let completions = try await db.run {
            try await LearningHistoryLocalDataSource.liveValue.allCompletions()
        }

        XCTAssertEqual(completions.count, 1)
        XCTAssertEqual(completions.first?.lessonID, 1)
        XCTAssertEqual(completions.first?.studyCount, 1)
        XCTAssertEqual(completions.first?.firstCompletedAt, date)
        XCTAssertEqual(completions.first?.lastStudiedAt, date)
    }

    func test_같은_레슨을_다시_완료하면_studyCount가_증가하고_firstCompletedAt은_보존된다() async throws {
        let db = LocalDatabaseTestContext()
        let firstDate = Date(timeIntervalSince1970: 0)
        let secondDate = Date(timeIntervalSince1970: 1000)

        try await db.run {
            let dataSource = LearningHistoryLocalDataSource.liveValue
            try await dataSource.recordCompletion(1, firstDate)
            try await dataSource.recordCompletion(1, secondDate)
        }

        let completions = try await db.run {
            try await LearningHistoryLocalDataSource.liveValue.allCompletions()
        }

        XCTAssertEqual(completions.count, 1)
        XCTAssertEqual(completions.first?.studyCount, 2)
        XCTAssertEqual(completions.first?.firstCompletedAt, firstDate)
        XCTAssertEqual(completions.first?.lastStudiedAt, secondDate)
    }

    func test_완료_기록이_없으면_빈_배열을_반환한다() async throws {
        let db = LocalDatabaseTestContext()

        let completions = try await db.run {
            try await LearningHistoryLocalDataSource.liveValue.allCompletions()
        }

        XCTAssertTrue(completions.isEmpty)
    }
}
