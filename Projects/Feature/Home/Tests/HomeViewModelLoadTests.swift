import XCTest

import DomainInterface
@testable import FeatureHome

import Dependencies

@MainActor
final class HomeViewModelLoadTests: XCTestCase {
    func test_load_성공시_state가_VocabularyLibrary로_채워진다() async {
        let vm = withDependencies {
            $0.getHomeOverviewUseCase = .previewValue
        } operation: {
            HomeViewModel()
        }

        await vm.load()

        XCTAssertNotNil(vm.state)
        XCTAssertFalse(vm.state?.levels.isEmpty ?? true)
    }

    func test_load_실패시_errorMessage가_설정된다() async {
        let vm = withDependencies {
            $0.getHomeOverviewUseCase.execute = { throw MockError.stub }
        } operation: {
            HomeViewModel()
        }

        await vm.load()

        XCTAssertNotNil(vm.errorMessage)
        XCTAssertNil(vm.state)
    }
}

private enum MockError: Error {
    case stub
}
