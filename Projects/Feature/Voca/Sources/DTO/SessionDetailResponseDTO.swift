import Foundation

public struct SessionDetailResponseDTO: Decodable {
    public struct Session: Decodable {
        public let id: String
        public let level: Int
        public let sessionNumber: Int
        public let title: String
        public let wordCount: Int
        public let estimatedMinutes: Int
        public let difficulty: String

        public init(
            id: String,
            level: Int,
            sessionNumber: Int,
            title: String,
            wordCount: Int,
            estimatedMinutes: Int,
            difficulty: String
        ) {
            self.id = id
            self.level = level
            self.sessionNumber = sessionNumber
            self.title = title
            self.wordCount = wordCount
            self.estimatedMinutes = estimatedMinutes
            self.difficulty = difficulty
        }
    }

    public struct LearningHistory: Decodable {
        public let firstCompletedAt: String
        public let lastStudiedAt: String
        public let reviewCount: Int
        public let averageAccuracy: Double

        public init(
            firstCompletedAt: String,
            lastStudiedAt: String,
            reviewCount: Int,
            averageAccuracy: Double
        ) {
            self.firstCompletedAt = firstCompletedAt
            self.lastStudiedAt = lastStudiedAt
            self.reviewCount = reviewCount
            self.averageAccuracy = averageAccuracy
        }
    }

    public struct Word: Decodable {
        public struct Definition: Decodable {
            public let id: String
            public let partOfSpeech: String
            public let meaning: String

            public init(
                id: String,
                partOfSpeech: String,
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

    public let session: Session
    public let learningHistory: LearningHistory?
    public let words: [Word]

    public init(session: Session, learningHistory: LearningHistory?, words: [Word]) {
        self.session = session
        self.learningHistory = learningHistory
        self.words = words
    }
}
