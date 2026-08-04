import Foundation

import DomainInterface

struct WordDetailPresentationModel: Equatable {
    struct DefinitionGroup: Equatable, Identifiable {
        let partOfSpeech: String
        let meanings: [String]

        var id: String { partOfSpeech }
    }

    struct ExampleRow: Equatable, Identifiable {
        let id: Int
        let en: String
        let ko: String
        let chunks: [WordDetail.Example.Chunk]?
        let words: [WordDetail.Example.Word]?
    }

    let term: String
    let pronunciation: String
    let definitionGroups: [DefinitionGroup]
    let examples: [ExampleRow]
}
