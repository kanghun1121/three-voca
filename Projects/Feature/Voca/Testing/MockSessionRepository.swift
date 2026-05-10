import Foundation

import FeatureVocaInterface

public final class MockSessionRepository: SessionRepository {
    public init() {}

    public func fetchSessionDetail(id: String) async throws -> Session {
        try await Task.sleep(for: .milliseconds(Int.random(in: 300...500)))
        return Self.sampleWithRecord(id: id)
    }

    public static func sampleWithRecord(id: String) -> Session {
        Session(
            id: id,
            level: 1,
            sessionNumber: 2,
            estimatedDurationMinutes: 15,
            cefrLevel: "A1-A2",
            words: sampleWords,
            record: Session.Record(
                firstCompletedAt: iso.date(from: "2026-05-01T10:23:45Z") ?? .distantPast,
                lastStudiedAt: iso.date(from: "2026-05-09T18:30:00Z") ?? .distantPast,
                reviewCount: 3,
                averageAccuracy: 0.87
            )
        )
    }

    public static func sampleWithoutRecord(id: String) -> Session {
        Session(
            id: id,
            level: 1,
            sessionNumber: 2,
            estimatedDurationMinutes: 15,
            cefrLevel: "A1-A2",
            words: sampleWords,
            record: nil
        )
    }

    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    static let sampleWords: [Session.Word] = [
        Session.Word(
            id: "word_001",
            term: "ambiguous",
            pronunciation: "/æmˈbɪɡjuəs/",
            definitions: [
                Session.Word.Definition(
                    id: "def_001_1",
                    partOfSpeech: .adjective,
                    meaning: "모호한, 애매한"
                )
            ]
        ),
        Session.Word(
            id: "word_002",
            term: "persevere",
            pronunciation: "/ˌpɜːrsəˈvɪr/",
            definitions: [
                Session.Word.Definition(
                    id: "def_002_1",
                    partOfSpeech: .verb,
                    meaning: "끈기 있게 계속하다, 인내하다"
                )
            ]
        ),
        Session.Word(
            id: "word_003",
            term: "eloquent",
            pronunciation: "/ˈeləkwənt/",
            definitions: [
                Session.Word.Definition(
                    id: "def_003_1",
                    partOfSpeech: .adjective,
                    meaning: "유창한, 능변의"
                )
            ]
        ),
        Session.Word(
            id: "word_004",
            term: "inevitable",
            pronunciation: "/ɪnˈevɪtəbl/",
            definitions: [
                Session.Word.Definition(
                    id: "def_004_1",
                    partOfSpeech: .adjective,
                    meaning: "불가피한, 필연적인"
                ),
                Session.Word.Definition(
                    id: "def_004_2",
                    partOfSpeech: .noun,
                    meaning: "피할 수 없는 일"
                ),
            ]
        ),
        Session.Word(
            id: "word_005",
            term: "meticulous",
            pronunciation: "/məˈtɪkjuləs/",
            definitions: [
                Session.Word.Definition(
                    id: "def_005_1",
                    partOfSpeech: .adjective,
                    meaning: "꼼꼼한, 세심한"
                )
            ]
        ),
        Session.Word(
            id: "word_006",
            term: "benevolent",
            pronunciation: "/bəˈnevələnt/",
            definitions: [
                Session.Word.Definition(
                    id: "def_006_1",
                    partOfSpeech: .adjective,
                    meaning: "자비로운, 친절한"
                )
            ]
        ),
        Session.Word(
            id: "word_007",
            term: "ephemeral",
            pronunciation: "/ɪˈfemərəl/",
            definitions: [
                Session.Word.Definition(
                    id: "def_007_1",
                    partOfSpeech: .adjective,
                    meaning: "덧없는, 단명하는"
                )
            ]
        ),
        Session.Word(
            id: "word_008",
            term: "resilient",
            pronunciation: "/rɪˈzɪliənt/",
            definitions: [
                Session.Word.Definition(
                    id: "def_008_1",
                    partOfSpeech: .adjective,
                    meaning: "회복력 있는, 탄력적인"
                )
            ]
        ),
        Session.Word(
            id: "word_009",
            term: "tenacious",
            pronunciation: "/təˈneɪʃəs/",
            definitions: [
                Session.Word.Definition(
                    id: "def_009_1",
                    partOfSpeech: .adjective,
                    meaning: "끈질긴, 고집스러운"
                )
            ]
        ),
        Session.Word(
            id: "word_010",
            term: "serene",
            pronunciation: "/səˈriːn/",
            definitions: [
                Session.Word.Definition(
                    id: "def_010_1",
                    partOfSpeech: .adjective,
                    meaning: "고요한, 평온한"
                )
            ]
        ),
        Session.Word(
            id: "word_011",
            term: "arduous",
            pronunciation: "/ˈɑːrdjuəs/",
            definitions: [
                Session.Word.Definition(
                    id: "def_011_1",
                    partOfSpeech: .adjective,
                    meaning: "힘든, 고된"
                )
            ]
        ),
        Session.Word(
            id: "word_012",
            term: "pragmatic",
            pronunciation: "/præɡˈmætɪk/",
            definitions: [
                Session.Word.Definition(
                    id: "def_012_1",
                    partOfSpeech: .adjective,
                    meaning: "실용적인, 현실적인"
                )
            ]
        ),
        Session.Word(
            id: "word_013",
            term: "vivid",
            pronunciation: "/ˈvɪvɪd/",
            definitions: [
                Session.Word.Definition(
                    id: "def_013_1",
                    partOfSpeech: .adjective,
                    meaning: "생생한, 선명한"
                )
            ]
        ),
        Session.Word(
            id: "word_014",
            term: "profound",
            pronunciation: "/prəˈfaʊnd/",
            definitions: [
                Session.Word.Definition(
                    id: "def_014_1",
                    partOfSpeech: .adjective,
                    meaning: "심오한, 깊은"
                )
            ]
        ),
        Session.Word(
            id: "word_015",
            term: "subtle",
            pronunciation: "/ˈsʌtl/",
            definitions: [
                Session.Word.Definition(
                    id: "def_015_1",
                    partOfSpeech: .adjective,
                    meaning: "미묘한, 섬세한"
                )
            ]
        ),
    ]
}

public final class MockEmptyRecordRepository: SessionRepository {
    public init() {}

    public func fetchSessionDetail(id: String) async throws -> Session {
        MockSessionRepository.sampleWithoutRecord(id: id)
    }
}
