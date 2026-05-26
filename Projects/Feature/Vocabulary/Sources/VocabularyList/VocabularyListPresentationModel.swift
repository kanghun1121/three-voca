import Foundation

struct VocabularyListPresentationModel: Equatable {
    struct WordRow: Equatable, Identifiable {
        let id: String
        let term: String
        let pronunciation: String
        let primaryMeaning: String
    }

    let level: Int
    let sessionNumber: Int
    let wordCount: Int
    let hasRecord: Bool
    let words: [WordRow]
}
