import XCTest

@testable import FeatureChatBot

final class MarkdownInlineParserTests: XCTestCase {
    func test_평문은_속성없이_그대로_반환된다() {
        let result = MarkdownInlineParser.parse("hello world")

        XCTAssertEqual(String(result.characters), "hello world")
        for run in result.runs {
            XCTAssertNil(run.inlinePresentationIntent)
            XCTAssertNil(run.link)
            XCTAssertNil(run.markdownHighlight)
        }
    }

    func test_굵게_문법이_stronglyEmphasized로_파싱된다() {
        let result = MarkdownInlineParser.parse("**굵게**")

        XCTAssertEqual(String(result.characters), "굵게")
        XCTAssertEqual(result.runs.first?.inlinePresentationIntent, .stronglyEmphasized)
    }

    func test_기울임_문법이_emphasized로_파싱된다() {
        let result = MarkdownInlineParser.parse("*기울임*")

        XCTAssertEqual(String(result.characters), "기울임")
        XCTAssertEqual(result.runs.first?.inlinePresentationIntent, .emphasized)
    }

    func test_인라인코드_문법이_code로_파싱된다() {
        let result = MarkdownInlineParser.parse("`코드`")

        XCTAssertEqual(String(result.characters), "코드")
        XCTAssertEqual(result.runs.first?.inlinePresentationIntent, .code)
    }

    func test_하이라이트_문법이_markdownHighlight_속성으로_파싱된다() {
        let result = MarkdownInlineParser.parse("==하이라이트==")

        XCTAssertEqual(String(result.characters), "하이라이트")
        XCTAssertEqual(result.runs.first?.markdownHighlight, true)
    }

    func test_링크_문법이_link_속성으로_파싱된다() {
        let result = MarkdownInlineParser.parse("[텍스트](https://example.com)")

        XCTAssertEqual(String(result.characters), "텍스트")
        XCTAssertEqual(result.runs.first?.link, URL(string: "https://example.com"))
    }

    func test_굵게와_평문이_섞이면_run_경계가_나뉜다() {
        let result = MarkdownInlineParser.parse("이건 **굵게** 텍스트")

        XCTAssertEqual(String(result.characters), "이건 굵게 텍스트")
        let runs = Array(result.runs)
        XCTAssertEqual(runs.count, 3)
        XCTAssertNil(runs[0].inlinePresentationIntent)
        XCTAssertEqual(runs[1].inlinePresentationIntent, .stronglyEmphasized)
        XCTAssertNil(runs[2].inlinePresentationIntent)
    }

    func test_짝이_맞지_않는_하이라이트는_평문으로_남는다() {
        let result = MarkdownInlineParser.parse("==하이라이트")

        XCTAssertEqual(String(result.characters), "==하이라이트")
        for run in result.runs {
            XCTAssertNil(run.markdownHighlight)
        }
    }

    func test_하이라이트_안에_굵게가_함께_적용된다() {
        let result = MarkdownInlineParser.parse("==**강조**==")

        XCTAssertEqual(String(result.characters), "강조")
        let run = result.runs.first
        XCTAssertEqual(run?.inlinePresentationIntent, .stronglyEmphasized)
        XCTAssertEqual(run?.markdownHighlight, true)
    }

    func test_빈_문자열은_빈_결과를_반환한다() {
        let result = MarkdownInlineParser.parse("")

        XCTAssertTrue(result.characters.isEmpty)
    }
}
