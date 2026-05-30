import Dependencies
import XCTest

@testable import FeatureVocabulary

@MainActor
final class VocabularyListViewModelTests: XCTestCase {
    func test_load_성공시_viewState가_loaded로_전환된다() async {
        let vm = withDependencies {
            $0.sessionClient = .previewValue
        } operation: {
            VocabularyListViewModel(sessionID: "t")
        }

        await vm.load()

        guard case .loaded = vm.viewState else {
            XCTFail("viewState가 .loaded여야 합니다. 실제: \(vm.viewState)")
            return
        }
    }

    func test_load_실패시_viewState가_error로_전환된다() async {
        let vm = withDependencies {
            $0.sessionClient.fetchSessionDetail = { _ in throw MockError.stub }
        } operation: {
            VocabularyListViewModel(sessionID: "t")
        }

        await vm.load()

        guard case .error = vm.viewState else {
            XCTFail("viewState가 .error여야 합니다. 실제: \(vm.viewState)")
            return
        }
    }

    func test_load_성공시_단어목록이_비어있지_않다() async {
        let vm = withDependencies {
            $0.sessionClient = .previewValue
        } operation: {
            VocabularyListViewModel(sessionID: "t")
        }

        await vm.load()

        if case .loaded(let pm) = vm.viewState {
            XCTAssertFalse(pm.words.isEmpty)
            XCTAssertGreaterThan(pm.wordCount, 0)
        } else {
            XCTFail("viewState가 .loaded여야 합니다.")
        }
    }

    func test_세션_단어수_텍스트가_올바르게_표시된다() async {
        let vm = withDependencies {
            $0.sessionClient = .previewValue
        } operation: {
            VocabularyListViewModel(sessionID: "t")
        }

        await vm.load()

        if case .loaded(let pm) = vm.viewState {
            // previewWithRecord는 15개 단어를 가짐
            XCTAssertEqual(pm.wordCount, 15)
            XCTAssertEqual(pm.words.count, 15)
        } else {
            XCTFail("viewState가 .loaded여야 합니다.")
        }
    }

    func test_세션정보_level과_sessionNumber가_올바르게_매핑된다() async {
        let vm = withDependencies {
            $0.sessionClient = .previewValue
        } operation: {
            VocabularyListViewModel(sessionID: "t")
        }

        await vm.load()

        if case .loaded(let pm) = vm.viewState {
            // previewWithRecord: level 1, sessionNumber 2
            XCTAssertEqual(pm.level, 1)
            XCTAssertEqual(pm.sessionNumber, 2)
        } else {
            XCTFail("viewState가 .loaded여야 합니다.")
        }
    }

    func test_wordTapped_호출시_destination이_wordDetail로_설정된다() {
        let vm = withDependencies {
            $0.sessionClient = .previewValue
        } operation: {
            VocabularyListViewModel(sessionID: "t")
        }

        vm.wordTapped(id: "word_1")

        guard case .wordDetail(let detailVM) = vm.destination else {
            XCTFail("destination이 .wordDetail이어야 합니다. 실제: \(String(describing: vm.destination))")
            return
        }
        _ = detailVM
    }

    func test_wordTapped_초기에는_destination이_nil이다() {
        let vm = withDependencies {
            $0.sessionClient = .previewValue
        } operation: {
            VocabularyListViewModel(sessionID: "t")
        }

        XCTAssertNil(vm.destination)
    }
}

private enum MockError: Error {
    case stub
}
