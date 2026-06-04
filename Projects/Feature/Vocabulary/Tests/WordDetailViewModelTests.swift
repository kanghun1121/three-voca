import Dependencies
import XCTest

@testable import FeatureVocabulary

@MainActor
final class WordDetailViewModelTests: XCTestCase {
    func test_load_성공시_viewState가_loaded로_전환된다() async {
        let vm = withDependencies {
            $0.wordClient = .previewValue
        } operation: {
            WordDetailViewModel(wordIDs: ["word_766"], initialIndex: 0)
        }

        await vm.requestIfNeeded(at: 0)

        guard case .loaded = vm.viewStates[0] else {
            XCTFail("viewState가 .loaded여야 합니다. 실제: \(String(describing: vm.viewStates[0]))")
            return
        }
    }

    func test_load_실패시_viewState가_error로_전환된다() async {
        let vm = withDependencies {
            $0.wordClient.fetchWordDetail = { _ in throw MockError.stub }
            $0.wordClient.prefetchWordDetails = { _ in }
        } operation: {
            WordDetailViewModel(wordIDs: ["word_766"], initialIndex: 0)
        }

        await vm.requestIfNeeded(at: 0)

        guard case .error = vm.viewStates[0] else {
            XCTFail("viewState가 .error여야 합니다. 실제: \(String(describing: vm.viewStates[0]))")
            return
        }
    }

    func test_load_성공시_term이_올바르게_매핑된다() async {
        let vm = withDependencies {
            $0.wordClient = .previewValue
        } operation: {
            WordDetailViewModel(wordIDs: ["word_766"], initialIndex: 0)
        }

        await vm.requestIfNeeded(at: 0)

        if case .loaded(let pm) = vm.viewStates[0] {
            XCTAssertEqual(pm.term, "dark")
            XCTAssertEqual(pm.pronunciation, "/dɑːrk/")
        } else {
            XCTFail("viewState가 .loaded여야 합니다.")
        }
    }

    func test_load_성공시_품사별_정의그룹이_올바르게_생성된다() async {
        let vm = withDependencies {
            $0.wordClient = .previewValue
        } operation: {
            WordDetailViewModel(wordIDs: ["word_766"], initialIndex: 0)
        }

        await vm.requestIfNeeded(at: 0)

        if case .loaded(let pm) = vm.viewStates[0] {
            // dark: adjective("어두운"), noun("어둠") — 2개 그룹
            XCTAssertEqual(pm.definitionGroups.count, 2)
            XCTAssertEqual(pm.definitionGroups[0].partOfSpeech, "형용사")
            XCTAssertEqual(pm.definitionGroups[0].meanings, ["어두운"])
            XCTAssertEqual(pm.definitionGroups[1].partOfSpeech, "명사")
            XCTAssertEqual(pm.definitionGroups[1].meanings, ["어둠"])
        } else {
            XCTFail("viewState가 .loaded여야 합니다.")
        }
    }

    func test_load_성공시_예문이_order_순으로_정렬된다() async {
        let vm = withDependencies {
            $0.wordClient = .previewValue
        } operation: {
            WordDetailViewModel(wordIDs: ["word_766"], initialIndex: 0)
        }

        await vm.requestIfNeeded(at: 0)

        if case .loaded(let pm) = vm.viewStates[0] {
            XCTAssertEqual(pm.examples.count, 2)
            XCTAssertEqual(pm.examples[0].id, 1)
            XCTAssertEqual(pm.examples[1].id, 2)
        } else {
            XCTFail("viewState가 .loaded여야 합니다.")
        }
    }
}

private enum MockError: Error {
    case stub
}
