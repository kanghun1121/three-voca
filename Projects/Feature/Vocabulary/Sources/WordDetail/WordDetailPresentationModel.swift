import Foundation

struct WordDetailPresentationModel: Equatable {
    struct DefinitionGroup: Equatable {
        let partOfSpeech: String
        let meanings: [String]
    }

    struct ExampleRow: Equatable, Identifiable {
        let id: Int
        let en: String
        let ko: String
    }

    let term: String
    let pronunciation: String
    let definitionGroups: [DefinitionGroup]
    let examples: [ExampleRow]
}
