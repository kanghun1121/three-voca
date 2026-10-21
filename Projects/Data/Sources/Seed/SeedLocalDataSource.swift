import Foundation
import SwiftData

import Core
import NetworkingInterface

import Dependencies
import DependenciesMacros

/// 서버 시드 응답 전체를 로컬 DB에 저장한다. 시드는 API 하나로 통째로 받으므로 도메인별
/// DataSource로 나누지 않고, `ChatHistoryLocalDataSource.save`처럼 한 번의 컨텍스트 진입 안에서
/// 전부 삽입하고 한 번만 `save()`한다 — 중간에 에러가 나면 아무것도 커밋되지 않는다.
@DependencyClient
struct SeedLocalDataSource: Sendable {
    /// 레벨이 하나도 없으면 시드가 아직 저장되지 않은 상태다.
    var isEmpty: @Sendable () async throws -> Bool
    var save: @Sendable (_ response: SeedDataResponseDTO) async throws -> Void
}

extension SeedLocalDataSource: DependencyKey {
    static let liveValue = SeedLocalDataSource(
        isEmpty: {
            @Dependency(\.localDatabaseContext) var context
            var descriptor = FetchDescriptor<LevelEntity>()
            descriptor.fetchLimit = 1
            return try await context.fetch(descriptor).isEmpty
        },
        save: { response in
            @Dependency(\.localDatabaseContext) var context
            try await context.withContext { modelContext in
                response.toEntities().forEach { modelContext.insert($0) }
                try modelContext.save()
            }
        }
    )
}

extension SeedLocalDataSource: UnimplementedTestDependencyKey {}

extension DependencyValues {
    var seedLocalDataSource: SeedLocalDataSource {
        get { self[SeedLocalDataSource.self] }
        set { self[SeedLocalDataSource.self] = newValue }
    }
}

private extension SeedDataResponseDTO {
    func toEntities() -> [any PersistentModel] {
        let distractorsByWordID = distractors.reduce(into: [Int: [String]]()) { result, item in
            result[item.wordId] = item.distractors
        }
        // rank 오름차순으로 정렬해서 저장한다 — 조회 시(Entities+Mapping.swift)도 다시 정렬하지만,
        // 저장 단계가 정렬을 빠뜨리는 회귀를 막는 이중 방어.
        let meaningsByWordID = Dictionary(grouping: wordMeanings, by: \.wordId)
            .mapValues { rows in
                rows.sorted { $0.rank < $1.rank }.map {
                    WordMeaningPayload(id: $0.id, pos: $0.pos, ko: $0.ko, rank: $0.rank)
                }
            }
        // position 오름차순으로 정렬해서 저장한다 — 배열 인덱스가 곧 정렬 결과이므로 여기서
        // 한 번만 정렬하면 이후 조회에서 다시 정렬할 필요가 없다.
        let wordIDsByLessonID = Dictionary(grouping: lessonWords, by: \.lessonId)
            .mapValues { rows in rows.sorted { $0.position < $1.position }.map(\.wordId) }

        let levelEntities: [any PersistentModel] = levels.map {
            LevelEntity(id: $0.id, nameKo: $0.nameKo, cefrLabel: $0.cefrLabel, sortOrder: $0.sortOrder)
        }
        let lessonEntities: [any PersistentModel] = lessons.map {
            LessonEntity(
                id: $0.id,
                levelID: $0.levelId,
                lessonNumber: $0.lessonNumber,
                orderedWordIDs: wordIDsByLessonID[$0.id] ?? []
            )
        }
        let wordEntities: [any PersistentModel] = words.map {
            WordEntity(
                id: $0.id,
                word: $0.word,
                levelID: $0.levelId,
                pronunciation: $0.pronunciation,
                // 서버 값이 URL로 해석되지 않아도 저장이 중단되지 않도록 원본 문자열을 그대로 둔다.
                audioUrl: URL(string: $0.audioUrl, relativeTo: SupabaseConfig.baseURL)?.absoluteURL.absoluteString
                    ?? $0.audioUrl,
                distractors: distractorsByWordID[$0.id] ?? [],
                meanings: meaningsByWordID[$0.id] ?? []
            )
        }
        let exampleEntities: [any PersistentModel] = wordExamples.map {
            WordExampleEntity(
                id: $0.id,
                wordID: $0.wordId,
                order: $0.order,
                sentenceEn: $0.sentenceEn,
                sentenceKo: $0.sentenceKo,
                words: ($0.words ?? []).map { ExampleWordPayload(word: $0.word, pos: $0.pos, meaning: $0.meaning) },
                chunks: ($0.chunks ?? []).map { ExampleChunkPayload(text: $0.text, meaning: $0.meaning) }
            )
        }
        return levelEntities + lessonEntities + wordEntities + exampleEntities
    }
}
