import Dependencies
import DomainInterface
import XCTest

@testable import FeatureVoca

@MainActor
final class SessionDetailViewModelTests: XCTestCase {
    func test_load_success_setsState() async {
        let vm = withDependencies {
            $0.sessionClient = .previewValue
        } operation: {
            SessionDetailViewModel(sessionID: "t")
        }
        await vm.load()
        XCTAssertNotNil(vm.state)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    func test_load_failure_setsErrorMessage() async {
        let vm = withDependencies {
            $0.sessionClient.fetchSessionDetail = { _ in throw TestError.mock }
        } operation: {
            SessionDetailViewModel(sessionID: "t")
        }
        await vm.load()
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertNil(vm.state)
        XCTAssertFalse(vm.isLoading)
    }
}

final class SessionMappingTests: XCTestCase {
    func test_title_shows_wordCount() {
        let session = Session.previewWithRecord(id: "t")
        let state = session.toSessionDetailViewState()
        XCTAssertEqual(state.title, "15개 단어")
    }

    func test_moreText_shows_remaining_after_preview() {
        let session = Session.previewWithRecord(id: "t")
        let state = session.toSessionDetailViewState(previewLimit: 4)
        XCTAssertEqual(state.moreText, "+ 11 more")
    }

    func test_nilRecord_returns_nilRecordViewState() {
        let session = Session.previewWithoutRecord(id: "t")
        let state = session.toSessionDetailViewState()
        XCTAssertNil(state.record)
    }

    func test_hasRecord_returns_recordViewState() {
        let session = Session.previewWithRecord(id: "t")
        let state = session.toSessionDetailViewState()
        XCTAssertNotNil(state.record)
    }

    func test_multipleDefinitions_primaryMeaning_usesFirst() {
        let session = Session.previewWithRecord(id: "t")
        let inevitableWord = session.words.first { $0.term == "inevitable" }!
        XCTAssertEqual(inevitableWord.definitions.count, 2)
        let state = session.toSessionDetailViewState(previewLimit: 15)
        let item = state.previewItems.first { $0.id == "word_004" }!
        XCTAssertEqual(item.primaryMeaning, "불가피한, 필연적인")
    }
}

private enum TestError: Error {
    case mock
}
