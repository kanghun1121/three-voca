import XCTest

import DomainInterface

import Dependencies

@testable import FeatureWordGame

@MainActor
final class SpellingViewModelTests: XCTestCase {
    func test_복습라운드에서_첫글자가_힌트로_채워진다() async {
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
            $0.soundClient = .previewValue
        } operation: {
            SpellingViewModel(
                words: [word],
                onCompleted: {},
                onClose: {}
            )
        }

        vm.load()
        vm.skipButtonTapped()
        try? await Task.sleep(for: .milliseconds(1150))

        XCTAssertTrue(vm.isReviewRound)
        XCTAssertEqual(vm.inputText, "c")
        XCTAssertEqual(vm.slots.first, .hint("c"))
    }

    func test_5개중_3개_오답_2개_정답이면_복습라운드에_오답3개가_순서대로_들어간다() async {
        let terms = ["cat", "dog", "sun", "cup", "run"]
        let words = terms.enumerated().map { index, term -> GameWord in
            let sessionWord = Session.Word(
                id: "w\(index)",
                term: term,
                pronunciation: "",
                definitions: [],
                distractors: [],
                audioUrl: ""
            )
            return GameWord(from: sessionWord)
        }
        let vm = withDependencies {
            $0.soundClient = .previewValue
        } operation: {
            SpellingViewModel(
                words: words,
                onCompleted: {},
                onClose: {}
            )
        }

        vm.load()

        vm.inputText = "zzz" // cat 오답
        try? await Task.sleep(for: .milliseconds(1150))
        vm.inputText = "dog" // dog 정답
        try? await Task.sleep(for: .milliseconds(650))
        vm.inputText = "zzz" // sun 오답
        try? await Task.sleep(for: .milliseconds(1150))
        vm.inputText = "zzz" // cup 오답
        try? await Task.sleep(for: .milliseconds(1150))
        vm.inputText = "run" // run 정답
        try? await Task.sleep(for: .milliseconds(650))

        XCTAssertTrue(vm.isReviewRound)
        XCTAssertEqual(vm.totalWords, 3)
        XCTAssertEqual(vm.currentWord?.term, "cat")

        vm.inputText = "cat"
        try? await Task.sleep(for: .milliseconds(650))
        XCTAssertEqual(vm.currentWord?.term, "sun")

        vm.inputText = "sun"
        try? await Task.sleep(for: .milliseconds(650))
        XCTAssertEqual(vm.currentWord?.term, "cup")
    }

    func test_메인라운드에서_스킵버튼을_모두_누르면_전부_복습배열에_들어간다() async {
        let terms = ["cat", "dog", "sun"]
        let words = terms.enumerated().map { index, term -> GameWord in
            let sessionWord = Session.Word(
                id: "w\(index)",
                term: term,
                pronunciation: "",
                definitions: [],
                distractors: [],
                audioUrl: ""
            )
            return GameWord(from: sessionWord)
        }
        let vm = withDependencies {
            $0.soundClient = .previewValue
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
            try? await Task.sleep(for: .milliseconds(1150))
        }

        XCTAssertTrue(vm.isReviewRound)
        XCTAssertEqual(vm.totalWords, terms.count)
    }

    func test_대문자를_입력해도_소문자로_비교되어_정답처리된다() {
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
            $0.soundClient = .previewValue
        } operation: {
            SpellingViewModel(
                words: [word],
                onCompleted: {},
                onClose: {}
            )
        }

        vm.load()
        vm.inputText = "CAT"

        XCTAssertEqual(vm.viewState, .correct)
    }

    func test_종료버튼을_누르면_destination이_alert상태가_된다() {
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
            $0.soundClient = .previewValue
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

    func test_리뷰라운드일때_SlotState가_hint_cursor_empty이다() async {
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
            $0.soundClient = .previewValue
        } operation: {
            SpellingViewModel(
                words: [word],
                onCompleted: {},
                onClose: {}
            )
        }

        vm.load()
        vm.skipButtonTapped()
        try? await Task.sleep(for: .milliseconds(1150))

        XCTAssertEqual(vm.slots, [.hint("c"), .cursor, .empty])
    }

    func test_일반라운드일때_SlotState가_cursor_empty_empty이다() {
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
            $0.soundClient = .previewValue
        } operation: {
            SpellingViewModel(
                words: [word],
                onCompleted: {},
                onClose: {}
            )
        }

        vm.load()

        XCTAssertEqual(vm.slots, [.cursor, .empty, .empty])
    }

    func test_5글자중_4글자입력시_복습라운드에서_hint_filled_filled_filled_cursor이다() async {
        let sessionWord = Session.Word(
            id: "w1",
            term: "apple",
            pronunciation: "",
            definitions: [],
            distractors: [],
            audioUrl: ""
        )
        let word = GameWord(from: sessionWord)
        let vm = withDependencies {
            $0.soundClient = .previewValue
        } operation: {
            SpellingViewModel(
                words: [word],
                onCompleted: {},
                onClose: {}
            )
        }

        vm.load()
        vm.skipButtonTapped()
        try? await Task.sleep(for: .milliseconds(1150))

        vm.inputText = "appl"

        XCTAssertEqual(
            vm.slots,
            [.hint("a"), .filled("p"), .filled("p"), .filled("l"), .cursor]
        )
    }

    func test_게임이_종료되면_onCompleted가_호출된다() async {
        let sessionWord = Session.Word(
            id: "w1",
            term: "cat",
            pronunciation: "",
            definitions: [],
            distractors: [],
            audioUrl: ""
        )
        let word = GameWord(from: sessionWord)
        var isCompleted = false
        let vm = withDependencies {
            $0.soundClient = .previewValue
        } operation: {
            SpellingViewModel(
                words: [word],
                onCompleted: { isCompleted = true },
                onClose: {}
            )
        }

        vm.load()
        vm.inputText = "cat"
        try? await Task.sleep(for: .milliseconds(650))

        XCTAssertTrue(isCompleted)
    }
}
