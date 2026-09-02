import XCTest

import Dependencies

@testable import FeatureChatBot
@testable import FeatureVocabulary

@MainActor
final class WordDetailViewModelTests: XCTestCase {
    func test_requestIfNeeded_index1_loaded이며_데이터가_올바르다() async {
        let vm = withDependencies {
            $0.getWordDetailUseCase = .previewValue
        } operation: {
            WordDetailViewModel(wordIDs: ["word_001", "word_766"], initialIndex: 0)
        }

        await vm.requestIfNeeded(at: 1)

        guard case .loaded(let pm) = vm.viewStates[1] else {
            XCTFail("viewStates[1]이 .loaded여야 합니다. 실제: \(String(describing: vm.viewStates[1]))")
            return
        }
        XCTAssertEqual(pm.term, "dark")
        XCTAssertEqual(pm.level, 1)
        XCTAssertEqual(pm.pronunciation, "/dɑːrk/")
        XCTAssertEqual(pm.definitionGroups.count, 2)
        XCTAssertEqual(pm.examples.count, 2)
    }

    func test_requestIfNeeded_실패시_viewState가_error로_전환된다() async {
        let vm = withDependencies {
            $0.getWordDetailUseCase.execute = { _ in throw MockError.stub }
        } operation: {
            WordDetailViewModel(wordIDs: ["word_001"], initialIndex: 0)
        }

        await vm.requestIfNeeded(at: 0)

        guard case .error = vm.viewStates[0] else {
            XCTFail("viewStates[0]이 .error여야 합니다. 실제: \(String(describing: vm.viewStates[0]))")
            return
        }
    }

    func test_didTapChatBot_예문컨텍스트로_챗봇destination을_세팅한다() async {
        let vm = withDependencies {
            $0.getWordDetailUseCase = .previewValue
        } operation: {
            WordDetailViewModel(wordIDs: ["word_766"], initialIndex: 0)
        }

        await vm.requestIfNeeded(at: 0)
        guard case .loaded(let pm) = vm.viewStates[0] else {
            XCTFail("viewStates[0]이 .loaded여야 합니다. 실제: \(String(describing: vm.viewStates[0]))")
            return
        }

        vm.didTapChatBot(state: pm, example: pm.examples[0])

        guard case .chatBot(let chatBotVM) = vm.destination else {
            XCTFail("destination이 .chatBot이어야 합니다. 실제: \(String(describing: vm.destination))")
            return
        }
        XCTAssertEqual(chatBotVM.context.term, "dark")
        XCTAssertEqual(chatBotVM.context.sentence, pm.examples[0].en)
        XCTAssertEqual(chatBotVM.context.levelLabel, "Level 1")
    }

    func test_requestIfNeeded_index1부터5까지_모두_loaded로_전환된다() async {
        let wordIDs = (0...5).map { "word_\(String(format: "%03d", $0))" }
        let vm = withDependencies {
            $0.getWordDetailUseCase = .previewValue
        } operation: {
            WordDetailViewModel(wordIDs: wordIDs, initialIndex: 0)
        }

        for index in 1...5 {
            await vm.requestIfNeeded(at: index)
        }

        for index in 1...5 {
            guard case .loaded = vm.viewStates[index] else {
                XCTFail("viewStates[\(index)]이 .loaded여야 합니다. 실제: \(String(describing: vm.viewStates[index]))")
                return
            }
        }
    }
}

private enum MockError: Error {
    case stub
}
