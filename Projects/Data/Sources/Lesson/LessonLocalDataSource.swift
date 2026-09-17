import Foundation
import SwiftData

import Dependencies

/// `LessonEntity`(정렬된 단어 id 목록 포함)만 소유한다. 단어 상세는 전혀 모른다 — 레슨에 속한
/// 단어를 실제로 조립하는 건 `WordLocalDataSource`를 함께 쓰는 `LessonRepository+Live`의 몫이다.
struct LessonLocalDataSource: Sendable {
    var lesson: @Sendable (_ id: Int) async throws -> LessonEntity?
    /// lessonNumber 오름차순 — LearningLibrary 레벨 안에서 레슨이 노출되는 순서다.
    var lessons: @Sendable (_ levelID: Int) async throws -> [LessonEntity]
    var insertLessons: @Sendable (_ lessons: [LessonEntity]) async -> Void
}

extension LessonLocalDataSource: DependencyKey {
    static let liveValue = LessonLocalDataSource(
        lesson: { id in
            @Dependency(\.localDatabaseContext) var context
            return try await context.fetch(FetchDescriptor<LessonEntity>(
                predicate: #Predicate { $0.id == id }
            )).first
        },
        lessons: { levelID in
            @Dependency(\.localDatabaseContext) var context
            return try await context.fetch(FetchDescriptor<LessonEntity>(
                predicate: #Predicate { $0.levelID == levelID },
                sortBy: [SortDescriptor(\.lessonNumber)]
            ))
        },
        insertLessons: { lessons in
            @Dependency(\.localDatabaseContext) var context
            for lesson in lessons { await context.insert(lesson) }
        }
    )
}

extension LessonLocalDataSource: TestDependencyKey {
    static let testValue = LessonLocalDataSource(
        lesson: unimplemented("\(Self.self).lesson"),
        lessons: unimplemented("\(Self.self).lessons"),
        insertLessons: unimplemented("\(Self.self).insertLessons", placeholder: ())
    )
}

extension DependencyValues {
    var lessonLocalDataSource: LessonLocalDataSource {
        get { self[LessonLocalDataSource.self] }
        set { self[LessonLocalDataSource.self] = newValue }
    }
}
