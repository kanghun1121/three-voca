import XCTest

@testable import FeatureVoca
import FeatureVocaInterface
import FeatureVocaTesting

@MainActor
final class SessionDetailViewModelTests: XCTestCase {
    func test_load_success_setsState() async throws {
        let vm = SessionDetailViewModel(sessionID: "t", repository: MockSessionRepository())
        await vm.load()
        XCTAssertNotNil(vm.state)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    func test_load_failure_setsErrorMessage() async throws {
        let vm = SessionDetailViewModel(sessionID: "t", repository: ThrowingRepository())
        await vm.load()
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertNil(vm.state)
        XCTAssertFalse(vm.isLoading)
    }
}

final class SessionMappingTests: XCTestCase {
    func test_title_shows_wordCount() {
        let session = MockSessionRepository.sampleWithRecord(id: "t")
        let state = session.toSessionDetailViewState()
        XCTAssertEqual(state.title, "15개 단어")
    }

    func test_moreText_shows_remaining_after_preview() {
        let session = MockSessionRepository.sampleWithRecord(id: "t")
        let state = session.toSessionDetailViewState(previewLimit: 4)
        XCTAssertEqual(state.moreText, "+ 11 more")
    }

    func test_nilRecord_returns_nilRecordViewState() {
        let session = MockSessionRepository.sampleWithoutRecord(id: "t")
        let state = session.toSessionDetailViewState()
        XCTAssertNil(state.record)
    }

    func test_hasRecord_returns_recordViewState() {
        let session = MockSessionRepository.sampleWithRecord(id: "t")
        let state = session.toSessionDetailViewState()
        XCTAssertNotNil(state.record)
    }
}

final class DTOMappingTests: XCTestCase {
    func test_partOfSpeech_unknownValue_mapsToUnknown() {
        let dto = SessionDetailResponseDTO.Word.Definition(
            id: "x",
            partOfSpeech: "determiner",
            meaning: "테스트"
        )
        let definition = dto.toDomain()
        XCTAssertEqual(definition.partOfSpeech, .unknown)
    }

    func test_knownPartOfSpeech_mapsCorrectly() {
        let dto = SessionDetailResponseDTO.Word.Definition(
            id: "y",
            partOfSpeech: "adjective",
            meaning: "모호한"
        )
        let definition = dto.toDomain()
        XCTAssertEqual(definition.partOfSpeech, .adjective)
    }

    func test_multipleDefinitions_primaryMeaning_usesFirst() {
        let session = MockSessionRepository.sampleWithRecord(id: "t")
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

private final class ThrowingRepository: SessionRepository {
    func fetchSessionDetail(id: String) async throws -> Session {
        throw TestError.mock
    }
}
