import XCTest

import DomainInterface

import Dependencies

@testable import FeatureHome

final class HomePresentationModelTests: XCTestCase {

    // MARK: - PresentationModel 매핑

    func test_toPresentationModel_icon_completed() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        let sessions = model.levels[0].sessions
        XCTAssertEqual(sessions[0].icon, .completedHigh)
        XCTAssertEqual(sessions[1].icon, .completedHigh)
        XCTAssertEqual(sessions[2].icon, .completedHigh)
        XCTAssertEqual(sessions[3].icon, .completedHigh)
        XCTAssertEqual(sessions[4].icon, .notStarted)
    }

    func test_toPresentationModel_status_active() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        XCTAssertEqual(model.levels[0].status, .active)
        XCTAssertEqual(model.levels[1].status, .notStarted)
    }

    func test_toPresentationModel_completedAndTotalSessions() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        XCTAssertEqual(model.levels[0].completedSessions, 4)
        XCTAssertEqual(model.levels[0].totalSessions, 42)
    }

    func test_toPresentationModel_progressRatio() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        let ratio = model.levels[0].progressRatio
        XCTAssertEqual(ratio, 4.0 / 42.0, accuracy: 0.001)
        XCTAssertEqual(model.levels[1].progressRatio, 0.0)
    }

    func test_toPresentationModel_sessionNumber_mapped() {
        let model = VocabularyLibrary.previewFixture.toHomePresentationModel()
        let sessions = model.levels[0].sessions
        XCTAssertEqual(sessions[0].sessionNumber, 1)
        XCTAssertEqual(sessions[1].sessionNumber, 2)
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
        XCTAssertEqual(viewModel.state?.levels.count, 4)
    }

    @MainActor
    func test_viewModel_load_setsHeatmapData() async {
        let viewModel = withDependencies {
            $0.homeClient = .previewValue
        } operation: {
            HomeViewModel()
        }
        await viewModel.load()
        XCTAssertFalse(viewModel.heatmapData.isEmpty)
    }

    @MainActor
    func test_viewModel_load_autoExpandsFirstActiveLevel() async {
        let viewModel = withDependencies {
            $0.homeClient = .previewValue
        } operation: {
            HomeViewModel()
        }
        await viewModel.load()
        XCTAssertEqual(viewModel.expandedLevelID, "level_1")
    }

    @MainActor
    func test_viewModel_load_failure_setsErrorMessage() async {
        let viewModel = withDependencies {
            $0.homeClient.fetchHomeOverview = { throw TestError.mock }
            $0.homeClient.fetchHeatmapData = { [] }
        } operation: {
            HomeViewModel()
        }
        await viewModel.load()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.state)
    }

    @MainActor
    func test_levelTapped_togglesExpansion() async {
        let viewModel = withDependencies {
            $0.homeClient = .previewValue
        } operation: {
            HomeViewModel()
        }
        await viewModel.load()

        let id = "level_1"
        XCTAssertEqual(viewModel.expandedLevelID, id)

        viewModel.levelTapped(id: id)
        XCTAssertNil(viewModel.expandedLevelID)

        viewModel.levelTapped(id: id)
        XCTAssertEqual(viewModel.expandedLevelID, id)
    }

    @MainActor
    func test_levelTapped_onlyOneExpanded() async {
        let viewModel = withDependencies {
            $0.homeClient = .previewValue
        } operation: {
            HomeViewModel()
        }
        await viewModel.load()

        viewModel.levelTapped(id: "level_2")
        XCTAssertEqual(viewModel.expandedLevelID, "level_2")
        XCTAssertNotEqual(viewModel.expandedLevelID, "level_1")
    }
}

private enum TestError: Error {
    case mock
}
