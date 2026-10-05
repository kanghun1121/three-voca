import XCTest

import DomainInterface

import Dependencies

@testable import FeatureWordGame

@MainActor
final class SpellingViewModelTests: XCTestCase {
    func test_복습라운드에서_첫글자가_힌트로_채워진다() async {
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
            $0.continuousClock = ImmediateClock()
            // [TestDependencyKey 제거] 기존 SoundClient.previewValue 인라인
            $0.soundClient = SoundClient(playCorrect: {}, playWrong: {})
        } operation: {
            SpellingViewModel(
                words: [word],
                onCompleted: {},
                onClose: {}
            )
        }

        vm.load()
        vm.skipButtonTapped()
        _ = await vm.advanceTask?.value

        XCTAssertTrue(vm.isReviewRound)
        XCTAssertEqual(vm.inputText, "c")
    }

    func test_5개중_3개_오답_2개_정답이면_복습라운드에_오답3개가_순서대로_들어간다() async {
        let terms = ["cat", "dog", "sun", "cup", "run"]
        let words = terms.enumerated().map { index, term -> Lesson.Word in
            let lessonWord = Lesson.Word(
                id: "w\(index)",
                term: term,
                pronunciation: "",
                definitions: [],
                distractors: [],
                audioUrl: ""
            )
            return lessonWord
        }
        let vm = withDependencies {
            $0.continuousClock = ImmediateClock()
            // [TestDependencyKey 제거] 기존 SoundClient.previewValue 인라인
            $0.soundClient = SoundClient(playCorrect: {}, playWrong: {})
        } operation: {
            SpellingViewModel(
                words: words,
                onCompleted: {},
                onClose: {}
            )
        }

        vm.load()

        vm.inputText = "zzz" // cat 오답
        vm.submitButtonTapped()
        _ = await vm.advanceTask?.value
        vm.inputText = "dog" // dog 정답
        vm.submitButtonTapped()
        _ = await vm.advanceTask?.value
        vm.inputText = "zzz" // sun 오답
        vm.submitButtonTapped()
        _ = await vm.advanceTask?.value
        vm.inputText = "zzz" // cup 오답
        vm.submitButtonTapped()
        _ = await vm.advanceTask?.value
        vm.inputText = "run" // run 정답
        vm.submitButtonTapped()
        _ = await vm.advanceTask?.value

        XCTAssertTrue(vm.isReviewRound)
        XCTAssertEqual(vm.totalWords, 3)
        XCTAssertEqual(vm.currentWord?.term, "cat")

        vm.inputText = "cat"
        vm.submitButtonTapped()
        _ = await vm.advanceTask?.value
        XCTAssertEqual(vm.currentWord?.term, "sun")

        vm.inputText = "sun"
        vm.submitButtonTapped()
        _ = await vm.advanceTask?.value
        XCTAssertEqual(vm.currentWord?.term, "cup")
    }

    func test_메인라운드에서_스킵버튼을_모두_누르면_전부_복습배열에_들어간다() async {
        let terms = ["cat", "dog", "sun"]
        let words = terms.enumerated().map { index, term -> Lesson.Word in
            let lessonWord = Lesson.Word(
                id: "w\(index)",
                term: term,
                pronunciation: "",
                definitions: [],
                distractors: [],
                audioUrl: ""
            )
            return lessonWord
        }
        let vm = withDependencies {
            $0.continuousClock = ImmediateClock()
            // [TestDependencyKey 제거] 기존 SoundClient.previewValue 인라인
            $0.soundClient = SoundClient(playCorrect: {}, playWrong: {})
        } operation: {
            SpellingViewModel(
                words: words,
                onCompleted: {},
                onClose: {}
            )
        }

        vm.load()
        for _ in terms {
            vm.skipButtonTapped()
            _ = await vm.advanceTask?.value
        }

        XCTAssertTrue(vm.isReviewRound)
        XCTAssertEqual(vm.totalWords, terms.count)
    }

    func test_대문자를_입력해도_소문자로_비교되어_정답처리된다() {
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
            $0.continuousClock = ImmediateClock()
            // [TestDependencyKey 제거] 기존 SoundClient.previewValue 인라인
            $0.soundClient = SoundClient(playCorrect: {}, playWrong: {})
        } operation: {
            SpellingViewModel(
                words: [word],
                onCompleted: {},
                onClose: {}
            )
        }

        vm.load()
        vm.inputText = "CAT"
        vm.submitButtonTapped()

        XCTAssertEqual(vm.viewState, .correct)
    }

    func test_종료버튼을_누르면_destination이_alert상태가_된다() {
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
            $0.continuousClock = ImmediateClock()
            // [TestDependencyKey 제거] 기존 SoundClient.previewValue 인라인
            $0.soundClient = SoundClient(playCorrect: {}, playWrong: {})
        } operation: {
            SpellingViewModel(
                words: [word],
                onCompleted: {},
                onClose: {}
            )
        }

        vm.closeButtonTapped()

        guard case .alert = vm.destination else {
            XCTFail("destination이 .alert여야 합니다. 실제: \(String(describing: vm.destination))")
            return
        }
    }

    func test_게임이_종료되면_onCompleted가_호출된다() async {
        let lessonWord = Lesson.Word(
            id: "w1",
            term: "cat",
            pronunciation: "",
            definitions: [],
            distractors: [],
            audioUrl: ""
        )
        let word = lessonWord
        var isCompleted = false
        let vm = withDependencies {
            $0.continuousClock = ImmediateClock()
            $0.soundClient = SoundClient(playCorrect: {}, playWrong: {})
        } operation: {
            SpellingViewModel(
                words: [word],
                onCompleted: { isCompleted = true },
                onClose: {}
            )
        }

        vm.load()
        vm.inputText = "cat"
        vm.submitButtonTapped()
        _ = await vm.advanceTask?.value

        XCTAssertTrue(isCompleted)
    }

    // MARK: - 제출 / 띄어쓰기 / 전체 지우기

    func test_정답을_입력해도_제출하기_전에는_판정하지_않는다() {
        let vm = makeViewModel(terms: ["cat"])

        vm.load()
        vm.inputText = "cat"

        XCTAssertEqual(vm.viewState, .active)
    }

    func test_입력이_비어있으면_제출할_수_없다() {
        let vm = makeViewModel(terms: ["cat"])

        vm.load()
        XCTAssertFalse(vm.canSubmit)

        vm.submitButtonTapped()
        XCTAssertEqual(vm.viewState, .active)

        vm.inputText = "c"
        XCTAssertTrue(vm.canSubmit)
    }

    func test_띄어쓰기를_맞춰_입력하고_제출하면_정답이다() {
        let vm = makeViewModel(terms: ["ice cream"])

        vm.load()
        vm.inputText = "ice cream"
        vm.submitButtonTapped()

        XCTAssertEqual(vm.viewState, .correct)
    }

    func test_띄어쓰기를_빼고_제출하면_오답이다() {
        let vm = makeViewModel(terms: ["ice cream"])

        vm.load()
        vm.inputText = "icecream"
        vm.submitButtonTapped()

        XCTAssertEqual(vm.viewState, .revealing)
    }

    func test_맨앞_공백과_연속_공백은_입력되지_않는다() {
        let vm = makeViewModel(terms: ["ice cream"])

        vm.load()
        vm.inputText = " ice  cream"

        XCTAssertEqual(vm.inputText, "ice cream")
    }

    func test_복습라운드에서도_전체_지우기로_입력을_모두_비울_수_있다() async {
        let vm = makeViewModel(terms: ["cat"])

        vm.load()
        vm.skipButtonTapped()
        _ = await vm.advanceTask?.value
        XCTAssertEqual(vm.inputText, "c")

        vm.inputText = ""

        XCTAssertEqual(vm.inputText, "")
    }

    private func makeViewModel(terms: [String]) -> SpellingViewModel {
        let words = terms.enumerated().map { index, term in
            Lesson.Word(
                id: "w\(index)",
                term: term,
                pronunciation: "",
                definitions: [],
                distractors: [],
                audioUrl: ""
            )
        }
        return withDependencies {
            $0.continuousClock = ImmediateClock()
            $0.soundClient = SoundClient(playCorrect: {}, playWrong: {})
        } operation: {
            SpellingViewModel(
                words: words,
                onCompleted: {},
                onClose: {}
            )
        }
    }
}
