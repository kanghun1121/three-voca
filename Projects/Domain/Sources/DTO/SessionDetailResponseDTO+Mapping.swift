import DomainInterface
import Foundation

extension SessionDetailResponseDTO {
    func toDomain() -> Session {
        Session(
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

private extension SessionDetailResponseDTO.Word {
    func toDomain() -> Session.Word {
        Session.Word(
            id: id,
            term: term,
            pronunciation: pronunciation,
            definitions: definitions.map { $0.toDomain() }
        )
    }
}

private extension SessionDetailResponseDTO.Word.Definition {
    func toDomain() -> Session.Word.Definition {
        Session.Word.Definition(
            id: id,
            partOfSpeech: Session.Word.Definition.PartOfSpeech(rawValue: partOfSpeech) ?? .unknown,
            meaning: meaning
        )
    }
}

private extension SessionDetailResponseDTO.LearningHistory {
    func toDomain() -> Session.Record {
        Session.Record(
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
