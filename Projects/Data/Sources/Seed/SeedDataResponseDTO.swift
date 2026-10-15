import Foundation

/// `get_seed_data` 응답. HTTPClient 디코더가 `convertFromSnakeCase`를 쓰므로 프로퍼티는
/// camelCase로만 선언한다(CodingKeys에 snake_case를 직접 쓰면 키가 어긋난다).
struct SeedDataResponseDTO: Decodable {
    let version: Int
    let changed: Bool
    let levels: [LevelDTO]
    let lessons: [LessonDTO]
    let lessonWords: [LessonWordDTO]
    let words: [WordDTO]
    let wordMeanings: [WordMeaningDTO]
    let wordExamples: [WordExampleDTO]
    let distractors: [DistractorDTO]

    struct LevelDTO: Decodable {
        let id: Int
        let nameKo: String
        let cefrLabel: String
        let sortOrder: Int
    }

    struct LessonDTO: Decodable {
        let id: Int
        let levelId: Int
        let lessonNumber: Int
        let wordCount: Int
    }

    struct LessonWordDTO: Decodable {
        let lessonId: Int
        let wordId: Int
        let position: Int
    }

    struct WordDTO: Decodable {
        let id: Int
        let word: String
        let levelId: Int
        let pronunciation: String
        let audioUrl: String
    }

    struct WordMeaningDTO: Decodable {
        let id: Int
        let wordId: Int
        let pos: String
        let ko: String
        let rank: Int
    }

    struct WordExampleDTO: Decodable {
        let id: Int
        let wordId: Int
        let order: Int
        let sentenceEn: String
        let sentenceKo: String
        let words: [ExampleWordDTO]?
        let chunks: [ExampleChunkDTO]?
    }

    struct ExampleWordDTO: Decodable {
        let word: String
        let pos: String
        let meaning: String
    }

    struct ExampleChunkDTO: Decodable {
        let text: String
        let meaning: String
    }

    struct DistractorDTO: Decodable {
        let wordId: Int
        let distractors: [String]
    }
}
