import Foundation
import SwiftData

import DomainInterface

import Dependencies

/// `WordEntity`(뜻 포함)+`WordExampleEntity`(전부 단어에 종속된 데이터)를 전담한다.
/// 단어 조회 API는 삭제되었으므로 Remote 대응 타입은 없다.
struct WordLocalDataSource: Sendable {
    var wordDetail: @Sendable (_ id: Int) async throws -> WordDetail
    /// Lesson 조립용 배치 조회 — 반환되는 딕셔너리엔 순서 정보가 없으므로, 호출부(Lesson
    /// LocalDataSource가 아는 lesson_words의 position)가 원하는 순서로 재조립해야 한다.
    var lessonWords: @Sendable (_ ids: [Int]) async throws -> [Int: Lesson.Word]
    var insertWords: @Sendable (_ words: [WordEntity]) async -> Void
    var insertExamples: @Sendable (_ examples: [WordExampleEntity]) async -> Void
}

extension WordLocalDataSource: DependencyKey {
    static let liveValue = WordLocalDataSource(
        wordDetail: { id in
            @Dependency(\.localDatabaseContext) var context
            guard let entity = try await context.fetch(FetchDescriptor<WordEntity>(
                predicate: #Predicate { $0.id == id }
            )).first else {
                throw LocalDatabaseError.wordNotFound(id)
            }
            let examples = try await context.fetch(FetchDescriptor<WordExampleEntity>(
                predicate: #Predicate { $0.wordID == id },
                sortBy: [SortDescriptor(\.order)]
            ))
            return entity.toWordDetail(examples: examples)
        },
        lessonWords: { ids in
            guard !ids.isEmpty else { return [:] }

            @Dependency(\.localDatabaseContext) var context
            let words = try await context.fetch(FetchDescriptor<WordEntity>(
                predicate: #Predicate { ids.contains($0.id) }
            ))

            return Dictionary(uniqueKeysWithValues: words.map { entity in
                (entity.id, entity.toLessonWord())
            })
        },
        insertWords: { words in
            @Dependency(\.localDatabaseContext) var context
            for word in words { await context.insert(word) }
        },
        insertExamples: { examples in
            @Dependency(\.localDatabaseContext) var context
            for example in examples { await context.insert(example) }
        }
    )
}

extension WordLocalDataSource: TestDependencyKey {
    static let testValue = WordLocalDataSource(
        wordDetail: unimplemented("\(Self.self).wordDetail"),
        lessonWords: unimplemented("\(Self.self).lessonWords"),
        insertWords: unimplemented("\(Self.self).insertWords", placeholder: ()),
        insertExamples: unimplemented("\(Self.self).insertExamples", placeholder: ())
    )
}

extension DependencyValues {
    var wordLocalDataSource: WordLocalDataSource {
        get { self[WordLocalDataSource.self] }
        set { self[WordLocalDataSource.self] = newValue }
    }
}
