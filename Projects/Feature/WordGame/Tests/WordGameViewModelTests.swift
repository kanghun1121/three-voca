import XCTest

import UseCaseInterface

import Dependencies

@testable import FeatureWordGame

@MainActor
final class WordGameViewModelTests: XCTestCase {
    func test_startingFrom에_spelling을_주입한경우_activeStage가_spelling이_된다() async {
        let vm = withDependencies {
            $0.sessionClient = .previewValue
        } operation: {
            WordGameViewModel(
                sessionID: "t",
                startingFrom: .spelling,
                audioPrefetchTask: Task {}
            )
        }

        await vm.load()

        guard case .spelling = vm.activeStage else {
            XCTFail("activeStage가 .spelling이어야 합니다. 실제: \(vm.activeStage)")
            return
        }
    }

    func test_게임이_끝났을때_sessionClient가_호출되고_dismiss된다() async {
        let word = Session.Word(
            id: "w1",
            term: "cat",
            pronunciation: "",
            definitions: [],
            distractors: [],
            audioUrl: ""
        )
        let session = Session(
            id: "5",
            level: 1,
            sessionNumber: 1,
            estimatedDurationMinutes: 1,
            cefrLevel: "A1",
            words: [word],
            record: nil
        )
        let recorder = CompleteSessionRecorder()

        // SpellingViewModel은 load() 내부에서 뒤늦게 생성되므로, soundClient 오버라이드가
        // 전파되도록 상호작용 전체를 async withDependencies 스코프 안에서 수행한다.
        await withDependencies {
            $0.sessionClient.fetchSessionDetail = { _ in session }
            $0.sessionClient.completeSession = { id in await recorder.record(id) }
            $0.soundClient = .previewValue
        } operation: {
            let vm = WordGameViewModel(
                sessionID: "5",
                startingFrom: .spelling,
                audioPrefetchTask: Task {}
            )

            await vm.load()

            guard case .spelling(let spellingVM) = vm.activeStage else {
                XCTFail("activeStage가 .spelling이어야 합니다. 실제: \(vm.activeStage)")
                return
            }

            spellingVM.load()
            spellingVM.inputText = "cat"
            _ = await spellingVM.advanceTask?.value

            guard case .gameComplete(_, let onDismiss) = vm.activeStage else {
                XCTFail("activeStage가 .gameComplete여야 합니다. 실제: \(vm.activeStage)")
                return
            }

            onDismiss()
            _ = await vm.finishGameTask?.value

            XCTAssertTrue(vm.dismiss)
            let completedID = await recorder.completedID
            XCTAssertEqual(completedID, 5)
        }
    }
}

private actor CompleteSessionRecorder {
    private(set) var completedID: Int?

    func record(_ id: Int) {
        completedID = id
    }
}
