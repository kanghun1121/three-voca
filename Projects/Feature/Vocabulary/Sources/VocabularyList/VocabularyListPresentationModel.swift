import Foundation

struct VocabularyListPresentationModel: Equatable {
    struct WordRow: Equatable, Identifiable {
        let id: String
        let term: String
        let pronunciation: String
        let primaryMeaning: String
    }

    let modeLabel: String
    let wordCountText: String
    let sessionInfoText: String
    let bottomBarText: String
    let words: [WordRow]
}
