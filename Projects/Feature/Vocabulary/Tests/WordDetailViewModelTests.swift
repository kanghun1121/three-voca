import Dependencies
import XCTest

@testable import FeatureVocabulary

@MainActor
final class WordDetailViewModelTests: XCTestCase {
    func test_load_성공시_viewState가_loaded로_전환된다() async {
        let vm = withDependencies {
            $0.wordClient = .previewValue
        } operation: {
            WordDetailViewModel(wordID: "word_766")
        }

        await vm.load()

        guard case .loaded = vm.viewState else {
            XCTFail("viewState가 .loaded여야 합니다. 실제: \(vm.viewState)")
            return
        }
    }

    func test_load_실패시_viewState가_error로_전환된다() async {
        let vm = withDependencies {
            $0.wordClient.fetchWordDetail = { _ in throw MockError.stub }
        } operation: {
            WordDetailViewModel(wordID: "word_766")
        }

        await vm.load()

        guard case .error = vm.viewState else {
            XCTFail("viewState가 .error여야 합니다. 실제: \(vm.viewState)")
            return
        }
    }

    func test_load_성공시_term이_올바르게_매핑된다() async {
        let vm = withDependencies {
            $0.wordClient = .previewValue
        } operation: {
            WordDetailViewModel(wordID: "word_766")
        }

        await vm.load()

        if case .loaded(let pm) = vm.viewState {
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
            WordDetailViewModel(wordID: "word_766")
        }

        await vm.load()

        if case .loaded(let pm) = vm.viewState {
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
            WordDetailViewModel(wordID: "word_766")
        }

        await vm.load()

        if case .loaded(let pm) = vm.viewState {
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
