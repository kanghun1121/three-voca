import Foundation

struct WordDetailResponseDTO: Decodable {
    struct DefinitionDTO: Decodable {
        let meaning: String
        let partOfSpeech: String
    }

    struct ExampleDTO: Decodable {
        let en: String
        let ko: String
        let order: Int
    }

    let id: String
    let term: String
    let level: Int
    let pronunciation: String
    let definitions: [DefinitionDTO]
    let examples: [ExampleDTO]
}
