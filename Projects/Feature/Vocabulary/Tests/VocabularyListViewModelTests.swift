import XCTest

import Dependencies

@testable import FeatureVocabulary

@MainActor
final class VocabularyListViewModelTests: XCTestCase {
    func test_load_실패시_viewState가_error로_전환된다() async {
        let vm = withDependencies {
            $0.getSessionDetailUseCase.execute = { _ in throw MockError.stub }
        } operation: {
            VocabularyListViewModel(sessionID: "t")
        }

        await vm.load()

        guard case .error = vm.viewState else {
            XCTFail("viewState가 .error여야 합니다. 실제: \(vm.viewState)")
            return
        }
    }

    func test_load_성공시_viewState가_loaded이며_Mock데이터가_올바르다() async {
        let vm = withDependencies {
            $0.getSessionDetailUseCase = .previewValue
            $0.prefetchWordDetailsUseCase.execute = { _ in }
            $0.prefetchAudioUseCase.execute = { _ in }
        } operation: {
            VocabularyListViewModel(sessionID: "t")
        }

        await vm.load()

        guard case .loaded(let session) = vm.viewState else {
            XCTFail("viewState가 .loaded여야 합니다. 실제: \(vm.viewState)")
            return
        }
        XCTAssertEqual(session.level, 1)
        XCTAssertEqual(session.sessionNumber, 2)
        XCTAssertEqual(session.words.count, 15)
    }

    func test_didTapWord_잘못된ID_호출시_destination이_nil이다() async {
        let vm = withDependencies {
            $0.getSessionDetailUseCase = .previewValue
            $0.prefetchWordDetailsUseCase.execute = { _ in }
            $0.prefetchAudioUseCase.execute = { _ in }
        } operation: {
            VocabularyListViewModel(sessionID: "t")
        }

        await vm.load()
        vm.didTapWord(id: "존재하지_않는_id")

        XCTAssertNil(vm.destination)
    }

    func test_didTapWord_정상ID_호출시_destination이_wordDetail로_설정된다() async {
        let vm = withDependencies {
            $0.getSessionDetailUseCase = .previewValue
            $0.prefetchWordDetailsUseCase.execute = { _ in }
            $0.prefetchAudioUseCase.execute = { _ in }
        } operation: {
            VocabularyListViewModel(sessionID: "t")
        }

        await vm.load()
        vm.didTapWord(id: "word_001")

        guard case .wordDetail = vm.destination else {
            XCTFail("destination이 .wordDetail이어야 합니다. 실제: \(String(describing: vm.destination))")
            return
        }
    }
}

private enum MockError: Error {
    case stub
}
