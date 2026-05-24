import Dependencies
import DomainInterface
import XCTest

@testable import FeatureSession

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
    func test_wordCount_matches_sessionWords() {
        let session = Session.previewWithRecord(id: "t")
        let state = session.toSessionDetailPresentationModel()
        XCTAssertEqual(state.wordCount, 15)
    }

    func test_level_and_sessionNumber_mapped() {
        let session = Session.previewWithRecord(id: "t")
        let state = session.toSessionDetailPresentationModel()
        XCTAssertEqual(state.level, session.level)
        XCTAssertEqual(state.sessionNumber, session.sessionNumber)
    }

    func test_estimatedDurationMinutes_and_cefrLevel_mapped() {
        let session = Session.previewWithRecord(id: "t")
        let state = session.toSessionDetailPresentationModel()
        XCTAssertEqual(state.estimatedDurationMinutes, session.estimatedDurationMinutes)
        XCTAssertEqual(state.cefrLevel, session.cefrLevel)
    }

    func test_words_contains_all_words() {
        let session = Session.previewWithRecord(id: "t")
        let state = session.toSessionDetailPresentationModel()
        XCTAssertEqual(state.words.count, 15)
    }

    func test_nilRecord_returns_nilRecord() {
        let session = Session.previewWithoutRecord(id: "t")
        let state = session.toSessionDetailPresentationModel()
        XCTAssertNil(state.record)
    }

    func test_hasRecord_returns_record() {
        let session = Session.previewWithRecord(id: "t")
        let state = session.toSessionDetailPresentationModel()
        XCTAssertNotNil(state.record)
    }

    func test_record_reviewCount_mapped() {
        let session = Session.previewWithRecord(id: "t")
        let state = session.toSessionDetailPresentationModel()
        XCTAssertEqual(state.record?.reviewCount, 3)
    }

    func test_record_averageAccuracyPercent_rounded() {
        let session = Session.previewWithRecord(id: "t")
        let state = session.toSessionDetailPresentationModel()
        XCTAssertEqual(state.record?.averageAccuracyPercent, 87)
    }

    func test_multipleDefinitions_primaryMeaning_usesFirst() {
        let session = Session.previewWithRecord(id: "t")
        let inevitableWord = session.words.first { $0.term == "inevitable" }!
        XCTAssertEqual(inevitableWord.definitions.count, 2)
        let state = session.toSessionDetailPresentationModel()
        let item = state.words.first { $0.id == "word_004" }!
        XCTAssertEqual(item.primaryMeaning, "불가피한, 필연적인")
    }
}

private enum TestError: Error {
    case mock
}
