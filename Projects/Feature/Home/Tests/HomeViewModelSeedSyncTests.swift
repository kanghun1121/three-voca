import XCTest

import DomainInterface
@testable import FeatureHome

import Dependencies

@MainActor
final class HomeViewModelSeedSyncTests: XCTestCase {
    func test_시드_동기화가_끝난_뒤에_학습_라이브러리를_새로고침한다() async {
        let events = LockIsolated<[String]>([])
        let vm = withDependencies {
            $0.date = .constant(.now)
            $0.seedRepository.syncIfNeeded = { events.withValue { $0.append("sync") } }
            $0.learningLibraryRepository.refresh = { events.withValue { $0.append("refresh") } }
        } operation: {
            HomeViewModel()
        }

        await vm.syncSeedIfNeeded()

        XCTAssertEqual(events.value, ["sync", "refresh"])
    }

    func test_시드_동기화가_실패하면_학습_라이브러리를_새로고침하지_않는다() async {
        struct SyncFailure: Error {}
        let refreshed = LockIsolated(false)
        let vm = withDependencies {
            $0.date = .constant(.now)
            $0.seedRepository.syncIfNeeded = { throw SyncFailure() }
            $0.learningLibraryRepository.refresh = { refreshed.setValue(true) }
        } operation: {
            HomeViewModel()
        }

        await vm.syncSeedIfNeeded()

        XCTAssertFalse(refreshed.value)
    }
}
