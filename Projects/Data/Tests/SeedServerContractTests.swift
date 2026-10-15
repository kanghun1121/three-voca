import XCTest

import NetworkingInterface

@testable import Data

/// 실제 서버의 `get_seed_data` 응답이 클라이언트 DTO로 디코딩되고 데이터 정합성을 만족하는지
/// 검증하는 계약 테스트. 네트워크에 의존하므로 일반 테스트 실행에서는 건너뛴다 —
/// `TEST_RUNNER_SEED_CONTRACT=1`을 주고 실행할 때만 동작한다(`.github/workflows/seed-contract.yml`).
final class SeedServerContractTests: XCTestCase {
    private var response: SeedDataResponseDTO!

    override func setUp() async throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["SEED_CONTRACT"] == "1",
            "서버 계약 테스트는 SEED_CONTRACT=1일 때만 실행한다"
        )

        // 앱과 같은 요청(`SeedDataRequest`)을 그대로 쓰되, 테스트 번들에는 Bundle.main의 anon key가
        // 없으므로 테스트 번들 Info.plist(Secrets.xcconfig 주입)에서 읽어 헤더만 채운다.
        let anonKey = try XCTUnwrap(
            Bundle(for: Self.self).object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
            "테스트 번들에 SUPABASE_ANON_KEY가 없다"
        )
        XCTAssertFalse(anonKey.isEmpty)

        var request = try SeedDataRequest().makeURLRequest()
        request.setValue(anonKey, forHTTPHeaderField: "apikey")

        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        let status = (urlResponse as? HTTPURLResponse)?.statusCode
        XCTAssertEqual(status, 200, "get_seed_data가 200이 아니다: \(String(decoding: data.prefix(300), as: UTF8.self))")

        // 실제 HTTPClient와 같은 디코더 설정.
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        response = try decoder.decode(SeedDataResponseDTO.self, from: data)
    }

    func test_응답이_DTO로_디코딩되고_모든_컬렉션이_비어_있지_않다() {
        XCTAssertGreaterThan(response.version, 0)
        XCTAssertFalse(response.levels.isEmpty)
        XCTAssertFalse(response.lessons.isEmpty)
        XCTAssertFalse(response.lessonWords.isEmpty)
        XCTAssertFalse(response.words.isEmpty)
        XCTAssertFalse(response.wordMeanings.isEmpty)
        XCTAssertFalse(response.wordExamples.isEmpty)
        XCTAssertFalse(response.distractors.isEmpty)
    }

    func test_id가_컬렉션_안에서_유일하다() {
        XCTAssertEqual(Set(response.levels.map(\.id)).count, response.levels.count, "levels id 중복")
        XCTAssertEqual(Set(response.lessons.map(\.id)).count, response.lessons.count, "lessons id 중복")
        XCTAssertEqual(Set(response.words.map(\.id)).count, response.words.count, "words id 중복")
        XCTAssertEqual(Set(response.wordExamples.map(\.id)).count, response.wordExamples.count, "word_examples id 중복")
    }

    func test_참조하는_id가_모두_존재한다() {
        let levelIDs = Set(response.levels.map(\.id))
        let lessonIDs = Set(response.lessons.map(\.id))
        let wordIDs = Set(response.words.map(\.id))

        XCTAssertEqual(Set(response.lessons.map(\.levelId)).subtracting(levelIDs), [], "lessons.level_id가 levels에 없다")
        XCTAssertEqual(Set(response.words.map(\.levelId)).subtracting(levelIDs), [], "words.level_id가 levels에 없다")
        XCTAssertEqual(Set(response.lessonWords.map(\.lessonId)).subtracting(lessonIDs), [], "lesson_words.lesson_id가 lessons에 없다")
        XCTAssertEqual(Set(response.lessonWords.map(\.wordId)).subtracting(wordIDs), [], "lesson_words.word_id가 words에 없다")
        XCTAssertEqual(Set(response.wordMeanings.map(\.wordId)).subtracting(wordIDs), [], "word_meanings.word_id가 words에 없다")
        XCTAssertEqual(Set(response.wordExamples.map(\.wordId)).subtracting(wordIDs), [], "word_examples.word_id가 words에 없다")
        XCTAssertEqual(Set(response.distractors.map(\.wordId)).subtracting(wordIDs), [], "distractors.word_id가 words에 없다")
    }

    func test_모든_단어에_뜻과_오답_선택지가_있다() {
        let withMeaning = Set(response.wordMeanings.map(\.wordId))
        let withDistractor = Set(response.distractors.filter { !$0.distractors.isEmpty }.map(\.wordId))
        let wordIDs = Set(response.words.map(\.id))

        XCTAssertEqual(wordIDs.subtracting(withMeaning), [], "뜻이 없는 단어")
        XCTAssertEqual(wordIDs.subtracting(withDistractor), [], "오답 선택지가 없는 단어")
    }

    func test_레슨_안에서_position이_중복되지_않는다() {
        let grouped = Dictionary(grouping: response.lessonWords, by: \.lessonId)
        let duplicated = grouped.filter { Set($0.value.map(\.position)).count != $0.value.count }.map(\.key)

        XCTAssertEqual(duplicated.sorted(), [], "position이 중복된 레슨")
    }
}
