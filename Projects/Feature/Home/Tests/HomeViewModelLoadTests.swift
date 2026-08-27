import XCTest

import Dependencies

@testable import FeatureHome
import DomainInterface

@MainActor
final class HomeViewModelLoadTests: XCTestCase {
    func test_load_성공시_state가_VocabularyLibrary로_채워진다() async {
        let vm = withDependencies {
            $0.getHomeOverviewUseCase = .previewValue
            $0.getHeatmapDataUseCase.execute = { [] }
        } operation: {
            HomeViewModel()
        }

        await vm.load()

        XCTAssertNotNil(vm.state)
        XCTAssertFalse(vm.state?.levels.isEmpty ?? true)
    }

    func test_load_성공시_active상태인_레벨이_자동으로_펼쳐진다() async {
        let vm = withDependencies {
            $0.getHomeOverviewUseCase = .previewValue
            $0.getHeatmapDataUseCase.execute = { [] }
        } operation: {
            HomeViewModel()
        }

        await vm.load()

        guard let activeLevel = vm.state?.levels.first(where: { $0.status == .active }) else {
            XCTFail("픽스처에 active 상태 레벨이 있어야 합니다.")
            return
        }
        XCTAssertTrue(vm.expandedLevelIDs.contains(activeLevel.id))
    }

    func test_load_실패시_errorMessage가_설정된다() async {
        let vm = withDependencies {
            $0.getHomeOverviewUseCase.execute = { throw MockError.stub }
            $0.getHeatmapDataUseCase.execute = { [] }
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
