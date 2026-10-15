import Foundation

import NetworkingInterface

/// 서버 시드 응답을 각 도메인 LocalDataSource의 삽입 메서드로 나눠 전달하는 오케스트레이션만
/// 담당한다. "이미 시딩됐는지" 판단은 `SeedRepository`의 책임이고, 실제 엔티티 삽입은 각
/// 도메인 DataSource의 책임이다 — 이 타입은 그 둘 사이를 순서대로 호출하고 마지막에
/// `context.save()`로 커밋할 뿐이다.
enum LocalDatabaseSeeder {
    static func seed(
        _ response: SeedDataResponseDTO,
        word: WordLocalDataSource,
        lesson: LessonLocalDataSource,
        level: LevelLocalDataSource,
        context: LocalDatabaseContext
    ) async throws {
        let distractorsByWordID = response.distractors.reduce(into: [Int: [String]]()) { result, item in
            result[item.wordId] = item.distractors
        }
        // rank 오름차순으로 정렬해서 저장한다 — 조회 시(Entities+Mapping.swift)도 다시 정렬하지만,
        // 시더가 정렬을 빠뜨리는 회귀를 막는 이중 방어.
        let meaningsByWordID = Dictionary(grouping: response.wordMeanings, by: \.wordId)
            .mapValues { rows in
                rows.sorted { $0.rank < $1.rank }.map {
                    WordMeaningPayload(id: $0.id, pos: $0.pos, ko: $0.ko, rank: $0.rank)
                }
            }
        // position 오름차순으로 정렬해서 저장한다 — 배열 인덱스가 곧 정렬 결과이므로 여기서
        // 한 번만 정렬하면 이후 조회에서 다시 정렬할 필요가 없다.
        let wordIDsByLessonID = Dictionary(grouping: response.lessonWords, by: \.lessonId)
            .mapValues { rows in rows.sorted { $0.position < $1.position }.map(\.wordId) }

        await level.insertLevels(response.levels.map {
            LevelEntity(id: $0.id, nameKo: $0.nameKo, cefrLabel: $0.cefrLabel, sortOrder: $0.sortOrder)
        })

        await lesson.insertLessons(response.lessons.map {
            LessonEntity(
                id: $0.id,
                levelID: $0.levelId,
                lessonNumber: $0.lessonNumber,
                orderedWordIDs: wordIDsByLessonID[$0.id] ?? []
            )
        })

        await word.insertWords(response.words.map {
            WordEntity(
                id: $0.id,
                word: $0.word,
                levelID: $0.levelId,
                pronunciation: $0.pronunciation,
                audioUrl: URL(string: $0.audioUrl, relativeTo: SupabaseConfig.baseURL)!.absoluteURL.absoluteString,
                distractors: distractorsByWordID[$0.id] ?? [],
                meanings: meaningsByWordID[$0.id] ?? []
            )
        })

        await word.insertExamples(response.wordExamples.map {
            WordExampleEntity(
                id: $0.id,
                wordID: $0.wordId,
                order: $0.order,
                sentenceEn: $0.sentenceEn,
                sentenceKo: $0.sentenceKo,
                words: ($0.words ?? []).map { ExampleWordPayload(word: $0.word, pos: $0.pos, meaning: $0.meaning) },
                chunks: ($0.chunks ?? []).map { ExampleChunkPayload(text: $0.text, meaning: $0.meaning) }
            )
        })

        // 전체를 한 번에 쌓고 마지막에 단 한 번만 저장한다 — 세 DataSource가 전부 같은
        // `LocalDatabaseContext`를 공유하므로(같은 ModelContext), 중간에 에러가 나면
        // 아무것도 커밋되지 않는다.
        try await context.save()
    }
}
