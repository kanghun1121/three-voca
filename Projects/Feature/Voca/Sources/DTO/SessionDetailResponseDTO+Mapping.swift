import Foundation

import FeatureVocaInterface

public extension SessionDetailResponseDTO {
    func toDomain() -> FeatureVocaInterface.Session {
        FeatureVocaInterface.Session(
            id: session.id,
            level: session.level,
            sessionNumber: session.sessionNumber,
            estimatedDurationMinutes: session.estimatedMinutes,
            cefrLevel: session.difficulty,
            words: words.map { $0.toDomain() },
            record: learningHistory?.toDomain()
        )
    }
}

public extension SessionDetailResponseDTO.Word {
    func toDomain() -> FeatureVocaInterface.Session.Word {
        FeatureVocaInterface.Session.Word(
            id: id,
            term: term,
            pronunciation: pronunciation,
            definitions: definitions.map { $0.toDomain() }
        )
    }
}

public extension SessionDetailResponseDTO.Word.Definition {
    func toDomain() -> FeatureVocaInterface.Session.Word.Definition {
        FeatureVocaInterface.Session.Word.Definition(
            id: id,
            partOfSpeech: FeatureVocaInterface.Session.Word.Definition.PartOfSpeech(rawValue: partOfSpeech) ?? .unknown,
            meaning: meaning
        )
    }
}

public extension SessionDetailResponseDTO.LearningHistory {
    func toDomain() -> FeatureVocaInterface.Session.Record {
        FeatureVocaInterface.Session.Record(
            firstCompletedAt: Self.iso8601.date(from: firstCompletedAt) ?? .distantPast,
            lastStudiedAt: Self.iso8601.date(from: lastStudiedAt) ?? .distantPast,
            reviewCount: reviewCount,
            averageAccuracy: averageAccuracy
        )
    }

    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
}
