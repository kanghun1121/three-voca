import SwiftData
import XCTest

@testable import Data

final class SeedLocalDataSourceTests: XCTestCase {
    func test_저장_전에는_비어_있고_저장_후에는_비어_있지_않다() async throws {
        let db = LocalDatabaseTestContext()
        let before = try await db.run { try await SeedLocalDataSource.liveValue.isEmpty() }

        try await db.run { try await SeedLocalDataSource.liveValue.save(try Self.response()) }
        let after = try await db.run { try await SeedLocalDataSource.liveValue.isEmpty() }

        XCTAssertTrue(before)
        XCTAssertFalse(after)
    }

    func test_응답의_4종_엔티티가_전부_저장된다() async throws {
        let db = LocalDatabaseTestContext()

        try await db.run { try await SeedLocalDataSource.liveValue.save(try Self.response()) }

        let levelCount = try await db.count(LevelEntity.self)
        let lessonCount = try await db.count(LessonEntity.self)
        let wordCount = try await db.count(WordEntity.self)
        let exampleCount = try await db.count(WordExampleEntity.self)
        XCTAssertEqual(levelCount, 1)
        XCTAssertEqual(lessonCount, 1)
        XCTAssertEqual(wordCount, 2)
        XCTAssertEqual(exampleCount, 1)
    }

    func test_단어에_뜻과_오답_선택지가_word_id_기준으로_결합된다() async throws {
        let db = LocalDatabaseTestContext()
        try await db.run { try await SeedLocalDataSource.liveValue.save(try Self.response()) }

        let words = try await db.context.fetch(FetchDescriptor<WordEntity>(predicate: #Predicate { $0.id == 1 }))
        let word = try XCTUnwrap(words.first)

        XCTAssertEqual(word.meanings.map(\.ko), ["하나", "둘"])
        XCTAssertEqual(word.meanings.map(\.rank), [1, 2])
        XCTAssertEqual(word.distractors, ["셋", "넷", "다섯"])
    }

    func test_레슨의_단어_순서는_position_오름차순이다() async throws {
        let db = LocalDatabaseTestContext()
        try await db.run { try await SeedLocalDataSource.liveValue.save(try Self.response()) }

        let lessons = try await db.context.fetch(FetchDescriptor<LessonEntity>())
        let lesson = try XCTUnwrap(lessons.first)

        XCTAssertEqual(lesson.orderedWordIDs, [2, 1])
    }

    func test_상대_audio_url은_서버_기준_절대_URL로_저장된다() async throws {
        let db = LocalDatabaseTestContext()
        try await db.run { try await SeedLocalDataSource.liveValue.save(try Self.response()) }

        let words = try await db.context.fetch(FetchDescriptor<WordEntity>(predicate: #Predicate { $0.id == 1 }))
        let word = try XCTUnwrap(words.first)

        XCTAssertTrue(word.audioUrl.hasPrefix("https://"))
        XCTAssertTrue(word.audioUrl.hasSuffix("/storage/a.mp3"))
    }

    // MARK: - Fixture

    private static func response() throws -> SeedDataResponseDTO {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(SeedDataResponseDTO.self, from: Data(json.utf8))
    }

    private static let json = """
    {
      "changed": true, "version": 6,
      "levels": [{"id": 1, "name_ko": "입문", "cefr_label": "A1", "sort_order": 1}],
      "lessons": [{"id": 10, "level_id": 1, "lesson_number": 1, "word_count": 2}],
      "lesson_words": [
        {"lesson_id": 10, "word_id": 1, "position": 2},
        {"lesson_id": 10, "word_id": 2, "position": 1}
      ],
      "words": [
        {"id": 1, "word": "a", "level_id": 1, "pronunciation": "a", "audio_url": "/storage/a.mp3"},
        {"id": 2, "word": "b", "level_id": 1, "pronunciation": "b", "audio_url": "/storage/b.mp3"}
      ],
      "word_meanings": [
        {"id": 2, "word_id": 1, "pos": "noun", "ko": "둘", "rank": 2},
        {"id": 1, "word_id": 1, "pos": "noun", "ko": "하나", "rank": 1}
      ],
      "word_examples": [{
        "id": 100, "word_id": 1, "order": 1,
        "sentence_en": "a", "sentence_ko": "가",
        "words": [{"word": "a", "pos": "noun", "meaning": "가"}],
        "chunks": [{"text": "a", "meaning": "가"}]
      }],
      "distractors": [{"word_id": 1, "distractors": ["셋", "넷", "다섯"]}]
    }
    """
}
