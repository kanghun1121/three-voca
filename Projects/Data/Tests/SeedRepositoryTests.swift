import SwiftData
import XCTest

import DomainInterface
import NetworkingInterface

import Dependencies

@testable import Data

final class SeedRepositoryTests: XCTestCase {
    func test_요청은_JWT_없이_apikey만으로_RPC를_POST로_호출한다() throws {
        let request = SeedDataRequest()
        let urlRequest = try request.makeURLRequest()
        let body = try XCTUnwrap(urlRequest.httpBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: String])

        XCTAssertEqual(urlRequest.url?.path, "/rest/v1/rpc/get_seed_data")
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(urlRequest.value(forHTTPHeaderField: "apikey"))
        XCTAssertNil(urlRequest.value(forHTTPHeaderField: "Authorization"))
        XCTAssertFalse(request.requiresAuthentication)
        XCTAssertTrue(json.isEmpty)
    }

    func test_로컬_DB가_비어_있으면_서버에서_받아_모든_컬렉션을_저장한다() async throws {
        let db = LocalDatabaseTestContext()
        let client = SeedStubHTTPClient(result: .success(Data(Self.fullResponse.utf8)))

        try await sync(db, client: client)

        let levels = try await db.context.fetch(FetchDescriptor<LevelEntity>())
        let lessons = try await db.context.fetch(FetchDescriptor<LessonEntity>())
        let words = try await db.context.fetch(FetchDescriptor<WordEntity>())
        let examples = try await db.context.fetch(FetchDescriptor<WordExampleEntity>())

        XCTAssertEqual(client.requestCount, 1)
        XCTAssertEqual(levels.map(\.nameKo), ["입문"])
        XCTAssertEqual(lessons.map(\.orderedWordIDs), [[765]])
        XCTAssertEqual(words.map(\.id), [765])
        XCTAssertEqual(words.first?.distractors, ["학생", "의사", "친구"])
        XCTAssertEqual(words.first?.meanings.map(\.ko), ["선생님"])
        XCTAssertEqual(examples.count, 1)
    }

    func test_예문의_words와_chunks가_그대로_보존된다() async throws {
        let db = LocalDatabaseTestContext()
        try await sync(db, client: SeedStubHTTPClient(result: .success(Data(Self.fullResponse.utf8))))

        let examples = try await db.context.fetch(FetchDescriptor<WordExampleEntity>())
        let example = try XCTUnwrap(examples.first)

        XCTAssertEqual(example.sentenceEn, "The teacher smiled.")
        XCTAssertEqual(example.words.map(\.word), ["teacher"])
        XCTAssertEqual(example.chunks.map(\.text), ["The teacher"])
    }

    func test_예문의_words와_chunks가_null이면_빈_배열로_저장된다() async throws {
        let db = LocalDatabaseTestContext()
        try await sync(db, client: SeedStubHTTPClient(result: .success(Data(Self.responseWithNullExampleParts.utf8))))

        let examples = try await db.context.fetch(FetchDescriptor<WordExampleEntity>())
        let example = try XCTUnwrap(examples.first)

        XCTAssertTrue(example.words.isEmpty)
        XCTAssertTrue(example.chunks.isEmpty)
    }

    func test_뜻은_rank_오름차순으로_레슨의_단어는_position_오름차순으로_저장된다() async throws {
        let db = LocalDatabaseTestContext()
        try await sync(db, client: SeedStubHTTPClient(result: .success(Data(Self.unorderedResponse.utf8))))

        let words = try await db.context.fetch(FetchDescriptor<WordEntity>())
        let word = try XCTUnwrap(words.first)
        let lessons = try await db.context.fetch(FetchDescriptor<LessonEntity>())
        let lesson = try XCTUnwrap(lessons.first)

        XCTAssertEqual(word.meanings.map(\.rank), [1, 2])
        XCTAssertEqual(lesson.orderedWordIDs, [2, 1])
    }

    func test_로컬_DB에_이미_시드가_있으면_서버를_호출하지_않는다() async throws {
        let db = LocalDatabaseTestContext()
        try await db.seed(LevelEntity(id: 1, nameKo: "기존", cefrLabel: "A1", sortOrder: 1))
        let client = SeedStubHTTPClient(result: .success(Data(Self.fullResponse.utf8)))

        try await sync(db, client: client)

        let levels = try await db.context.fetch(FetchDescriptor<LevelEntity>())
        XCTAssertEqual(client.requestCount, 0)
        XCTAssertEqual(levels.map(\.nameKo), ["기존"])
    }

    func test_서버가_실패하면_에러가_전파되고_로컬_DB는_비어_있다() async throws {
        let db = LocalDatabaseTestContext()
        let client = SeedStubHTTPClient(result: .failure(NetworkError.invalidRequest))

        do {
            try await sync(db, client: client)
            XCTFail("에러가 던져져야 한다")
        } catch {
            guard case .invalidRequest? = error as? NetworkError else {
                return XCTFail("NetworkError.invalidRequest가 그대로 전파되어야 한다: \(error)")
            }
        }

        let levels = try await db.context.fetch(FetchDescriptor<LevelEntity>())
        XCTAssertTrue(levels.isEmpty)
    }

    // MARK: - Helpers

    private func sync(_ db: LocalDatabaseTestContext, client: SeedStubHTTPClient) async throws {
        try await db.run {
            try await withDependencies {
                $0.httpClient = client
                $0.seedRemoteDataSource = .liveValue
            } operation: {
                try await SeedRepository.liveValue.syncIfNeeded()
            }
        }
    }

    private static let fullResponse = """
    {
      "changed": true,
      "version": 6,
      "levels": [{"id": 1, "name_ko": "입문", "name_en": "Beginner", "cefr_label": "A1", "description": "d", "sort_order": 1}],
      "lessons": [{"id": 10, "level_id": 1, "lesson_number": 1, "word_count": 20}],
      "lesson_words": [{"lesson_id": 10, "word_id": 765, "position": 1}],
      "words": [{"id": 765, "word": "teacher", "level_id": 1, "pronunciation": "/ˈtiːtʃər/", "audio_url": "/storage/teacher.mp3", "primary_pos": "noun", "all_pos": "noun"}],
      "word_meanings": [{"id": 1, "word_id": 765, "pos": "noun", "ko": "선생님", "rank": 1, "cefr": "A1", "note": ""}],
      "word_examples": [{
        "id": 100, "word_id": 765, "order": 1,
        "sentence_en": "The teacher smiled.", "sentence_ko": "선생님이 웃었다.",
        "words": [{"word_id": 765, "word": "teacher", "pos": "noun", "meaning": "선생님"}],
        "chunks": [{"text": "The teacher", "meaning": "선생님이"}]
      }],
      "distractors": [{"id": 1, "word_id": 765, "distractors": ["학생", "의사", "친구"]}]
    }
    """

    private static let responseWithNullExampleParts = """
    {
      "changed": true, "version": 6,
      "levels": [], "lessons": [], "lesson_words": [], "words": [], "word_meanings": [], "distractors": [],
      "word_examples": [{
        "id": 100, "word_id": 765, "order": 1,
        "sentence_en": "The teacher smiled.", "sentence_ko": "선생님이 웃었다.",
        "words": null, "chunks": null
      }]
    }
    """

    private static let unorderedResponse = """
    {
      "changed": true, "version": 6,
      "levels": [{"id": 1, "name_ko": "입문", "cefr_label": "A1", "sort_order": 1}],
      "lessons": [{"id": 10, "level_id": 1, "lesson_number": 1, "word_count": 2}],
      "lesson_words": [
        {"lesson_id": 10, "word_id": 1, "position": 2},
        {"lesson_id": 10, "word_id": 2, "position": 1}
      ],
      "words": [{"id": 1, "word": "a", "level_id": 1, "pronunciation": "a", "audio_url": "/a.mp3"}],
      "word_meanings": [
        {"id": 2, "word_id": 1, "pos": "noun", "ko": "둘", "rank": 2},
        {"id": 1, "word_id": 1, "pos": "noun", "ko": "하나", "rank": 1}
      ],
      "word_examples": [], "distractors": []
    }
    """
}

/// 실제 `HTTPClient`와 같은 디코더 설정(`convertFromSnakeCase`)으로 고정 응답을 디코딩한다.
private final class SeedStubHTTPClient: HTTPClienting, @unchecked Sendable {
    let result: Result<Data, Error>
    private(set) var requestCount = 0

    init(result: Result<Data, Error>) {
        self.result = result
    }

    func request<T: Decodable>(_ requestable: any Requestable) async throws -> T {
        requestCount += 1
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: try result.get())
    }

    func request(_ requestable: any Requestable) async throws {
        _ = try result.get()
    }

    func data(from url: URL) async throws -> Data {
        try result.get()
    }
}
