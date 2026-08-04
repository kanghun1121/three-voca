import Foundation

import DomainInterface

struct GameWord: Equatable, Identifiable {
    let id: String
    let term: String
    let pronunciation: String
    let primaryMeaning: String
    let distractors: [String]
    let audioUrl: String

    init(from word: Session.Word) {
        self.id = word.id
        self.term = word.term
        self.pronunciation = word.pronunciation
        self.primaryMeaning = word.definitions.first?.meaning ?? ""
        self.distractors = word.distractors
        self.audioUrl = word.audioUrl
    }
}
