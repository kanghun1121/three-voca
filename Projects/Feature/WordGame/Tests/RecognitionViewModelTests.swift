import XCTest

import DomainInterface

import Dependencies

@testable import FeatureWordGame

@MainActor
final class RecognitionViewModelTests: XCTestCase {
    func test_closeButton을_누르면_destination이_alert로_바뀌고_countdownTask가_취소된다() async {
        let lessonWord = Lesson.Word(
            id: "w1",
            term: "cat",
            pronunciation: "",
            definitions: [],
            distractors: [],
            audioUrl: ""
        )
        let word = lessonWord
        let vm = withDependencies {
            $0.audioRepository.url = { _ in nil }
            $0.audioRepository.fetchURL = { _, _ in nil }
            $0.audioPlayerRepository.play = { _ in }
            $0.audioPlayerRepository.stop = {}
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

        // 취소 직후 루프가 마지막으로 한 번 갱신하므로, 그 갱신이 끝난 뒤의 값을 기준으로 삼는다.
        try? await Task.sleep(for: .milliseconds(100))
        let progressAfterClose = vm.ringProgress

        // countdownTask가 취소됐다면, 대기 후에도 ringProgress가 변하지 않는다.
        try? await Task.sleep(for: .milliseconds(300))

        XCTAssertEqual(vm.ringProgress, progressAfterClose)
    }
}
