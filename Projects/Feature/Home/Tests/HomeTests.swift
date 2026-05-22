import Dependencies
import DomainInterface
import XCTest

@testable import FeatureHome

final class HomeViewStateTests: XCTestCase {

    // MARK: - ViewState 매핑

    func test_toViewState_lowAccuracyIcon() {
        let viewState = VocabularyLibrary.previewFixture.toHomeViewState()
        let sessions = viewState.levels[0].sessions
        XCTAssertEqual(sessions[0].icon, .completedHigh)   // 92%
        XCTAssertEqual(sessions[1].icon, .completedHigh)   // 87%
        XCTAssertEqual(sessions[2].icon, .completedLow)    // 58%
        XCTAssertEqual(sessions[3].icon, .completedHigh)   // 88%
        XCTAssertEqual(sessions[4].icon, .notStarted)
    }

    func test_toViewState_difficultyFormat() {
        let viewState = VocabularyLibrary.previewFixture.toHomeViewState()
        XCTAssertEqual(viewState.levels[0].subtitle, "A1·A2 · 4/13")
        XCTAssertFalse(viewState.levels[0].subtitle.contains("-"))
    }

    func test_toViewState_progressRatio() {
        let viewState = VocabularyLibrary.previewFixture.toHomeViewState()
        let ratio = viewState.levels[0].progressRatio
        XCTAssertEqual(ratio, 4.0 / 13.0, accuracy: 0.001)
        XCTAssertEqual(viewState.levels[1].progressRatio, 0.0)
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
