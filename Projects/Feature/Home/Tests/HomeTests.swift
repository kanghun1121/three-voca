import Dependencies
import DomainInterface
import XCTest

@testable import FeatureHome

final class HomePresentationModelTests: XCTestCase {

    // MARK: - PresentationModel 매핑

    func test_toPresentationModel_lowAccuracyIcon() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        let sessions = model.levels[0].sessions
        XCTAssertEqual(sessions[0].icon, .completedHigh)   // 92%
        XCTAssertEqual(sessions[1].icon, .completedHigh)   // 87%
        XCTAssertEqual(sessions[2].icon, .completedLow)    // 58%
        XCTAssertEqual(sessions[3].icon, .completedHigh)   // 88%
        XCTAssertEqual(sessions[4].icon, .notStarted)
    }

    func test_toPresentationModel_difficulty_rawValue() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        XCTAssertEqual(model.levels[0].difficulty, "A1-A2")
    }

    func test_toPresentationModel_completedAndTotalSessions() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        XCTAssertEqual(model.levels[0].completedSessions, 4)
        XCTAssertEqual(model.levels[0].totalSessions, 13)
    }

    func test_toPresentationModel_progressRatio() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        let ratio = model.levels[0].progressRatio
        XCTAssertEqual(ratio, 4.0 / 13.0, accuracy: 0.001)
        XCTAssertEqual(model.levels[1].progressRatio, 0.0)
    }

    func test_toPresentationModel_level_mapped() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        XCTAssertEqual(model.levels[0].level, 1)
        XCTAssertEqual(model.levels[1].level, 2)
    }

    func test_toPresentationModel_sessionNumber_mapped() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        let sessions = model.levels[0].sessions
        XCTAssertEqual(sessions[0].sessionNumber, 1)
        XCTAssertEqual(sessions[1].sessionNumber, 2)
    }

    func test_toPresentationModel_accuracyPercent_completed() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        let sessions = model.levels[0].sessions
        XCTAssertEqual(sessions[0].accuracyPercent, 92)
        XCTAssertEqual(sessions[2].accuracyPercent, 58)
    }

    func test_toPresentationModel_accuracyPercent_notStarted_isNil() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        let sessions = model.levels[0].sessions
        XCTAssertNil(sessions[4].accuracyPercent)
    }

    // MARK: - ViewModel

    @MainActor
    func test_viewModel_load_setsState() async {
        let viewModel = withDependencies {
            $0.homeClient = .previewValue
        } operation: {
            HomeViewModel()
        }
        XCTAssertNil(viewModel.state)
        await viewModel.load()
        XCTAssertNotNil(viewModel.state)
        XCTAssertEqual(viewModel.state?.levels.count, 3)
    }

    @MainActor
    func test_viewModel_load_failure_setsErrorMessage() async {
        let viewModel = withDependencies {
            $0.homeClient.fetchHomeOverview = { throw TestError.mock }
        } operation: {
            HomeViewModel()
        }
        await viewModel.load()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.state)
    }

    @MainActor
    func test_levelTapped_expandsAndCollapses() async {
        let viewModel = withDependencies {
            $0.homeClient = .previewValue
        } operation: {
            HomeViewModel()
        }
        await viewModel.load()

        let id = "level_1"
        XCTAssertFalse(viewModel.expandedLevelIDs.contains(id))

        viewModel.levelTapped(id: id)
        XCTAssertTrue(viewModel.expandedLevelIDs.contains(id))

        viewModel.levelTapped(id: id)
        XCTAssertFalse(viewModel.expandedLevelIDs.contains(id))
    }
}

private enum TestError: Error {
    case mock
}
