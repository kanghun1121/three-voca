import FeatureHomeInterface
import FeatureHomeTesting
import XCTest

@testable import FeatureHome

final class HomeTests: XCTestCase {

    // MARK: - DTO 디코딩

    func test_dtoDecoding_success() throws {
        let data = Data(sampleJSON.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(VocabularyLibraryResponseDTO.self, from: data)
        XCTAssertEqual(dto.levels.count, 3)
        XCTAssertEqual(dto.levels[0].id, "level_1")
        XCTAssertEqual(dto.levels[0].sessions.count, 6)
    }

    // MARK: - Domain 매핑

    func test_toDomain_statusMapping() throws {
        let data = Data(sampleJSON.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(VocabularyLibraryResponseDTO.self, from: data)
        let library = dto.toDomain()

        let sessions = library.levels[0].sessions
        XCTAssertEqual(sessions[0].status, .completed)
        XCTAssertEqual(sessions[4].status, .notStarted)
        XCTAssertEqual(sessions[5].status, .notStarted)
    }

    func test_toDomain_unknownStatus_fallsBackToNotStarted() throws {
        let json = """
        { "levels": [{ "id": "l1", "level": 1, "name": "test", "difficulty": "A1",
          "total_sessions": 1, "completed_sessions": 0,
          "sessions": [{ "id": "s1", "session_number": 1, "total_words": 10,
            "status": "invalid_value", "last_studied_at": null,
            "accuracy": null, "words_completed": 0 }]
        }]}
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(VocabularyLibraryResponseDTO.self, from: data)
        let library = dto.toDomain()
        XCTAssertEqual(library.levels[0].sessions[0].status, .notStarted)
    }

    // MARK: - ViewState 매핑

    func test_toViewState_lowAccuracyIcon() {
        let overview = MockHomeRepository.sampleVocabularyLibrary
        let viewState = overview.toHomeViewState()

        let sessions = viewState.levels[0].sessions
        XCTAssertEqual(sessions[0].icon, .completedHigh)   // 92%
        XCTAssertEqual(sessions[1].icon, .completedHigh)   // 87%
        XCTAssertEqual(sessions[2].icon, .completedLow)    // 58%
        XCTAssertEqual(sessions[3].icon, .completedHigh)   // 88%
        XCTAssertEqual(sessions[4].icon, .notStarted)
        XCTAssertEqual(sessions[5].icon, .notStarted)
    }

    func test_toViewState_difficultyFormat() {
        let overview = MockHomeRepository.sampleVocabularyLibrary
        let viewState = overview.toHomeViewState()
        XCTAssertEqual(viewState.levels[0].subtitle, "A1·A2 · 4/13")
        XCTAssertFalse(viewState.levels[0].subtitle.contains("-"))
    }

    func test_toViewState_progressRatio() {
        let overview = MockHomeRepository.sampleVocabularyLibrary
        let viewState = overview.toHomeViewState()
        let ratio = viewState.levels[0].progressRatio
        XCTAssertEqual(ratio, 4.0 / 13.0, accuracy: 0.001)
        XCTAssertEqual(viewState.levels[1].progressRatio, 0.0)
    }

    // MARK: - ViewModel

    @MainActor
    func test_viewModel_load_setsState() async {
        let viewModel = HomeViewModel(repository: MockHomeRepository())
        XCTAssertNil(viewModel.state)
        await viewModel.load()
        XCTAssertNotNil(viewModel.state)
        XCTAssertEqual(viewModel.state?.levels.count, 3)
    }

    @MainActor
    func test_toggleLevel_expandsAndCollapses() async {
        let viewModel = HomeViewModel(repository: MockHomeRepository())
        await viewModel.load()

        let id = "level_1"
        XCTAssertFalse(viewModel.expandedLevelIDs.contains(id))

        viewModel.toggleLevel(id: id)
        XCTAssertTrue(viewModel.expandedLevelIDs.contains(id))

        viewModel.toggleLevel(id: id)
        XCTAssertFalse(viewModel.expandedLevelIDs.contains(id))
    }

    // MARK: - Fixture

    private let sampleJSON = """
    {
      "levels": [
        {
          "id": "level_1", "level": 1, "name": "초등 기초", "difficulty": "A1-A2",
          "total_sessions": 13, "completed_sessions": 4,
          "sessions": [
            { "id": "s1", "session_number": 1, "total_words": 15, "status": "completed",
              "last_studied_at": "2026-05-03T14:20:00Z", "accuracy": 0.92, "words_completed": 15 },
            { "id": "s2", "session_number": 2, "total_words": 15, "status": "completed",
              "last_studied_at": "2026-05-09T10:15:00Z", "accuracy": 0.87, "words_completed": 15 },
            { "id": "s3", "session_number": 3, "total_words": 15, "status": "completed",
              "last_studied_at": "2026-05-06T20:45:00Z", "accuracy": 0.58, "words_completed": 15 },
            { "id": "s4", "session_number": 4, "total_words": 15, "status": "completed",
              "last_studied_at": "2026-05-08T08:10:00Z", "accuracy": 0.88, "words_completed": 15 },
            { "id": "s5", "session_number": 5, "total_words": 15, "status": "in_progress",
              "last_studied_at": "2026-05-10T09:30:00Z", "accuracy": null, "words_completed": 5 },
            { "id": "s6", "session_number": 6, "total_words": 15, "status": "not_started",
              "last_studied_at": null, "accuracy": null, "words_completed": 0 }
          ]
        },
        {
          "id": "level_2", "level": 2, "name": "초등 심화", "difficulty": "B1",
          "total_sessions": 17, "completed_sessions": 0,
          "sessions": [
            { "id": "l2s1", "session_number": 1, "total_words": 15, "status": "not_started",
              "last_studied_at": null, "accuracy": null, "words_completed": 0 }
          ]
        },
        {
          "id": "level_3", "level": 3, "name": "중등 기본", "difficulty": "B2",
          "total_sessions": 40, "completed_sessions": 0,
          "sessions": [
            { "id": "l3s1", "session_number": 1, "total_words": 15, "status": "not_started",
              "last_studied_at": null, "accuracy": null, "words_completed": 0 }
          ]
        }
      ]
    }
    """
}
