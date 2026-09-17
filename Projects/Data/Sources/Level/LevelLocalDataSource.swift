import Foundation
import SwiftData

import Dependencies

/// `LevelEntity`만 소유한다. Lesson(레슨 상세의 cefrLabel 조회)과 LearningLibrary(레벨
/// 목록 스켈레톤) 양쪽에서 재사용되어 별도 도메인으로 독립시켰다.
struct LevelLocalDataSource: Sendable {
    var level: @Sendable (_ id: Int) async throws -> LevelEntity?
    /// sortOrder 오름차순 — LearningLibrary 화면에 노출되는 레벨 순서다.
    var allLevels: @Sendable () async throws -> [LevelEntity]
    var insertLevels: @Sendable (_ levels: [LevelEntity]) async -> Void
}

extension LevelLocalDataSource: DependencyKey {
    static let liveValue = LevelLocalDataSource(
        level: { id in
            @Dependency(\.localDatabaseContext) var context
            return try await context.fetch(FetchDescriptor<LevelEntity>(
                predicate: #Predicate { $0.id == id }
            )).first
        },
        allLevels: {
            @Dependency(\.localDatabaseContext) var context
            return try await context.fetch(FetchDescriptor<LevelEntity>(
                sortBy: [SortDescriptor(\.sortOrder)]
            ))
        },
        insertLevels: { levels in
            @Dependency(\.localDatabaseContext) var context
            for level in levels {
                await context.insert(level)
            }
        }
    )
}

extension LevelLocalDataSource: TestDependencyKey {
    static let testValue = LevelLocalDataSource(
        level: unimplemented("\(Self.self).level"),
        allLevels: unimplemented("\(Self.self).allLevels"),
        insertLevels: unimplemented("\(Self.self).insertLevels", placeholder: ())
    )

    static let previewValue = LevelLocalDataSource(
        level: unimplemented("\(Self.self).level"),
        allLevels: unimplemented("\(Self.self).allLevels"),
        insertLevels: unimplemented("\(Self.self).insertLevels", placeholder: ())
    )
}


extension DependencyValues {
    var levelLocalDataSource: LevelLocalDataSource {
        get { self[LevelLocalDataSource.self] }
        set { self[LevelLocalDataSource.self] = newValue }
    }
}
