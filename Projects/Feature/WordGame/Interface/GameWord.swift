import Foundation

import DomainInterface

public struct GameWord: Equatable, Identifiable {
    public let id: String
    public let term: String
    public let pronunciation: String
    public let primaryMeaning: String

    public init(from word: Session.Word) {
        self.id = word.id
        self.term = word.term
        self.pronunciation = word.pronunciation
        self.primaryMeaning = word.definitions.first?.meaning ?? ""
    }
}
