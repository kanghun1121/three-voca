import Foundation

struct WordDetailResponseDTO: Decodable {
    struct DefinitionDTO: Decodable {
        let meaning: String
        let partOfSpeech: String
    }

    struct ExampleDTO: Decodable {
        struct WordDTO: Decodable {
            let word: String
            let meaning: String
            let pos: String
        }

        struct ChunkDTO: Decodable {
            let text: String
            let meaning: String
        }

        let en: String
        let ko: String
        let order: Int
        let words: String?
        let chunks: String?
    }

    let id: String
    let term: String
    let level: Int
    let pronunciation: String
    let definitions: [DefinitionDTO]
    let examples: [ExampleDTO]
}
