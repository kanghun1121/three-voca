import Foundation

public struct Session: Equatable {
    public struct Word: Equatable, Identifiable {
        public struct Definition: Equatable, Identifiable {
            public enum PartOfSpeech: String, Equatable {
                case noun
                case verb
                case adjective
                case adverb
                case preposition
                case conjunction
                case interjection
                case pronoun
                case unknown
            }

            public let id: String
            public let partOfSpeech: PartOfSpeech
            public let meaning: String

            public init(
                id: String,
                partOfSpeech: PartOfSpeech,
                meaning: String
            ) {
                self.id = id
                self.partOfSpeech = partOfSpeech
                self.meaning = meaning
            }
        }

        public let id: String
        public let term: String
        public let pronunciation: String
        public let definitions: [Definition]

        public init(
            id: String,
            term: String,
            pronunciation: String,
            definitions: [Definition]
        ) {
            self.id = id
            self.term = term
            self.pronunciation = pronunciation
            self.definitions = definitions
        }
    }

    public struct Record: Equatable {
        public let firstCompletedAt: Date
        public let lastStudiedAt: Date
        public let reviewCount: Int
        public let averageAccuracy: Double

        public init(
            firstCompletedAt: Date,
            lastStudiedAt: Date,
            reviewCount: Int,
            averageAccuracy: Double
        ) {
            self.firstCompletedAt = firstCompletedAt
            self.lastStudiedAt = lastStudiedAt
            self.reviewCount = reviewCount
            self.averageAccuracy = averageAccuracy
        }
    }

    public let id: String
    public let level: Int
    public let sessionNumber: Int
    public let estimatedDurationMinutes: Int
    public let cefrLevel: String
    public let words: [Word]
    public let record: Record?

    public init(
        id: String,
        level: Int,
        sessionNumber: Int,
        estimatedDurationMinutes: Int,
        cefrLevel: String,
        words: [Word],
        record: Record?
    ) {
        self.id = id
        self.level = level
        self.sessionNumber = sessionNumber
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.cefrLevel = cefrLevel
        self.words = words
        self.record = record
    }
}

public protocol SessionRepository {
    func fetchSessionDetail(id: String) async throws -> Session
}
