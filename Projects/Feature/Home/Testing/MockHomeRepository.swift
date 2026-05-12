import FeatureHomeInterface
import Foundation

public final class MockHomeRepository: HomeRepository {
    public init() {}

    public func fetchVocabularyLibrary() async throws -> VocabularyLibrary {
        try await Task.sleep(for: .milliseconds(Int.random(in: 300...500)))
        return MockHomeRepository.sampleVocabularyLibrary
    }

    // MARK: - Sample Fixtures

    public static let sampleVocabularyLibrary: VocabularyLibrary = {
        guard let url = Bundle.module.url(forResource: "vocabulary_library", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            fatalError("[MockHomeRepository] vocabulary_library.json 리소스를 찾을 수 없음")
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let payload = try? decoder.decode(LibraryPayload.self, from: data) else {
            fatalError("[MockHomeRepository] vocabulary_library.json 디코딩 실패")
        }
        return patchDemoSessions(payload.toDomain())
    }()

    // MARK: - Private

    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static func patchDemoSessions(_ library: VocabularyLibrary) -> VocabularyLibrary {
        let demoSessions: [(id: Int, accuracy: Double, date: String)] = [
            (1, 0.92, "2026-05-03T14:20:00Z"),
            (2, 0.87, "2026-05-09T10:15:00Z"),
            (3, 0.58, "2026-05-06T20:45:00Z"),
            (4, 0.88, "2026-05-08T08:10:00Z"),
        ]

        let levels = library.levels.enumerated().map { (index, level) -> LevelSummary in
            guard index == 0 else { return level }

            let patchedSessions = level.sessions.map { session -> SessionProgress in
                guard let demo = demoSessions.first(where: { $0.id == session.id }) else {
                    return session
                }
                return SessionProgress(
                    id: session.id,
                    sessionNumber: session.sessionNumber,
                    totalWords: session.totalWords,
                    status: .completed,
                    lastStudiedAt: iso.date(from: demo.date),
                    accuracy: demo.accuracy
                )
            }

            return LevelSummary(
                id: level.id,
                level: level.level,
                name: level.name,
                difficulty: level.difficulty,
                totalSessions: level.totalSessions,
                completedSessions: demoSessions.count,
                sessions: patchedSessions
            )
        }

        return VocabularyLibrary(levels: levels)
    }
}

// MARK: - Internal Decodable payload (Testing 타겟 전용)

private struct LibraryPayload: Decodable {
    let levels: [LevelPayload]

    struct LevelPayload: Decodable {
        let id: String
        let level: Int
        let name: String
        let difficulty: String
        let totalSessions: Int
        let completedSessions: Int
        let sessions: [SessionPayload]
    }

    struct SessionPayload: Decodable {
        let id: Int
        let sessionNumber: Int
        let totalWords: Int
        let status: String
        let lastStudiedAt: String?
        let accuracy: Double?
    }
}

private extension LibraryPayload {
    func toDomain() -> VocabularyLibrary {
        VocabularyLibrary(levels: levels.map { $0.toDomain() })
    }
}

private extension LibraryPayload.LevelPayload {
    func toDomain() -> LevelSummary {
        LevelSummary(
            id: id,
            level: level,
            name: name,
            difficulty: difficulty,
            totalSessions: totalSessions,
            completedSessions: completedSessions,
            sessions: sessions.map { $0.toDomain() }
        )
    }
}

private extension LibraryPayload.SessionPayload {
    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    func toDomain() -> SessionProgress {
        SessionProgress(
            id: id,
            sessionNumber: sessionNumber,
            totalWords: totalWords,
            status: SessionProgressStatus(rawValue: status) ?? .notStarted,
            lastStudiedAt: lastStudiedAt.flatMap { Self.iso.date(from: $0) },
            accuracy: accuracy
        )
    }
}
