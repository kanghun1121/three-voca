import XCTest

import DomainInterface

import Dependencies

@testable import FeatureWordGame

@MainActor
final class RecognitionViewModelTests: XCTestCase {
    func test_closeButton을_누르면_countdownTask가_취소되어_카운트다운이_끝나도_active상태를_유지한다() async {
        let sessionWord = Session.Word(
            id: "w1",
            term: "cat",
            pronunciation: "",
            definitions: [],
            distractors: [],
            audioUrl: ""
        )
        let word = GameWord(from: sessionWord)
        let vm = withDependencies {
            $0.audioClient = .previewValue
            $0.audioPlayerClient = .previewValue
        } operation: {
            RecognitionViewModel(
                words: [word],
                onCompleted: {},
                onClose: {}
            )
        }

        vm.start()
        try? await Task.sleep(for: .milliseconds(200))

        vm.closeButtonTapped()
        guard case .alert = vm.destination else {
            XCTFail("destination이 .alert여야 합니다. 실제: \(String(describing: vm.destination))")
            return
        }

        // 취소되지 않았다면 남은 카운트다운(약 2.8초) 후 .revealing으로 전환된다.
        try? await Task.sleep(for: .milliseconds(3300))

        XCTAssertEqual(vm.viewState, .active)
    }
}
