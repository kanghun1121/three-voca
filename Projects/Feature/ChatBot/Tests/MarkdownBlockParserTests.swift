import XCTest

@testable import FeatureChatBot

final class MarkdownBlockParserTests: XCTestCase {
    func test_빈_문자열이나_공백만_있으면_빈_배열을_반환한다() {
        XCTAssertEqual(MarkdownBlockParser.parse(""), [])
        XCTAssertEqual(MarkdownBlockParser.parse("   \n\n  "), [])
    }

    func test_헤딩_레벨과_텍스트가_파싱된다() {
        let blocks = MarkdownBlockParser.parse("# 헤딩1\n## 헤딩2\n### 헤딩3\n#### 헤딩4")

        XCTAssertEqual(blocks.count, 4)
        guard case let .heading(level0, text0) = blocks[0] else { return XCTFail("heading 아님") }
        XCTAssertEqual(level0, 1)
        XCTAssertEqual(String(text0.characters), "헤딩1")

        guard case let .heading(level1, text1) = blocks[1] else { return XCTFail("heading 아님") }
        XCTAssertEqual(level1, 2)
        XCTAssertEqual(String(text1.characters), "헤딩2")

        guard case let .heading(level2, text2) = blocks[2] else { return XCTFail("heading 아님") }
        XCTAssertEqual(level2, 3)
        XCTAssertEqual(String(text2.characters), "헤딩3")

        guard case let .heading(level3, text3) = blocks[3] else { return XCTFail("heading 아님") }
        XCTAssertEqual(level3, 4)
        XCTAssertEqual(String(text3.characters), "헤딩4")
    }

    func test_연속된_문단_줄이_하나로_병합된다() {
        let blocks = MarkdownBlockParser.parse("첫줄\n둘째줄\n\n다음 문단")

        XCTAssertEqual(blocks.count, 2)
        guard case let .paragraph(p1) = blocks[0] else { return XCTFail("paragraph 아님") }
        XCTAssertEqual(String(p1.characters), "첫줄 둘째줄")
        guard case let .paragraph(p2) = blocks[1] else { return XCTFail("paragraph 아님") }
        XCTAssertEqual(String(p2.characters), "다음 문단")
    }

    func test_불릿_중첩_들여쓰기가_depth로_반영된다() {
        let blocks = MarkdownBlockParser.parse("- 명사\n  - 주소라는 뜻\n- 동사")

        XCTAssertEqual(blocks.count, 1)
        guard case let .bulletList(items) = blocks[0] else { return XCTFail("bulletList 아님") }
        XCTAssertEqual(items.map(\.depth), [0, 1, 0])
        XCTAssertEqual(items.map { String($0.text.characters) }, ["명사", "주소라는 뜻", "동사"])
    }

    func test_결과대조_리스트의_kind가_정확히_구분된다() {
        let blocks = MarkdownBlockParser.parse("- ✓ You love me.\n- ✗ You love I.")

        XCTAssertEqual(blocks.count, 1)
        guard case let .resultList(items) = blocks[0] else { return XCTFail("resultList 아님") }
        XCTAssertEqual(items.map(\.kind), [.correct, .incorrect])
        XCTAssertEqual(String(items[0].text.characters), "You love me.")
        XCTAssertEqual(String(items[1].text.characters), "You love I.")
    }

    func test_일반_불릿과_결과대조가_섞이면_세그먼트가_나뉜다() {
        let blocks = MarkdownBlockParser.parse("- 일반 항목\n- ✓ 정답 항목")

        XCTAssertEqual(blocks.count, 2)
        guard case let .bulletList(items) = blocks[0] else { return XCTFail("첫 블록은 bulletList여야 함") }
        XCTAssertEqual(items.map { String($0.text.characters) }, ["일반 항목"])
        guard case let .resultList(results) = blocks[1] else { return XCTFail("둘째 블록은 resultList여야 함") }
        XCTAssertEqual(results.map(\.kind), [.correct])
    }

    func test_번호_리스트_순서가_유지된다() {
        let blocks = MarkdownBlockParser.parse("1. 첫번째\n2. 두번째")

        XCTAssertEqual(blocks.count, 1)
        guard case let .orderedList(items) = blocks[0] else { return XCTFail("orderedList 아님") }
        XCTAssertEqual(items.map { String($0.text.characters) }, ["첫번째", "두번째"])
    }

    func test_2열_표가_정확히_파싱된다() {
        let markdown = "| 주격 | 목적격 |\n|---|---|\n| I | me |\n| we | us |"
        let blocks = MarkdownBlockParser.parse(markdown)

        XCTAssertEqual(blocks.count, 1)
        guard case let .table(table) = blocks[0] else { return XCTFail("table 아님") }
        XCTAssertEqual(table.columnCount, 2)
        XCTAssertEqual(table.headers.map { String($0.characters) }, ["주격", "목적격"])
        XCTAssertEqual(table.rows.count, 2)
        XCTAssertEqual(table.rows[0].map { String($0.characters) }, ["I", "me"])
        XCTAssertEqual(table.rows[1].map { String($0.characters) }, ["we", "us"])
    }

    func test_3열_표가_정확히_파싱된다() {
        let markdown = "| 표현 | 뜻 | 예문 |\n|---|---|---|\n| this form | 지금 보는 서류 | 참고 |"
        let blocks = MarkdownBlockParser.parse(markdown)

        guard case let .table(table) = blocks[0] else { return XCTFail("table 아님") }
        XCTAssertEqual(table.columnCount, 3)
        XCTAssertEqual(table.rows[0].map { String($0.characters) }, ["this form", "지금 보는 서류", "참고"])
    }

    func test_4열_표가_정확히_파싱된다() {
        let markdown = "| 단어 | 품사 | 성분 | 뜻 |\n|---|---|---|---|\n| You | 대명사 | 주어 S | 너는 |"
        let blocks = MarkdownBlockParser.parse(markdown)

        guard case let .table(table) = blocks[0] else { return XCTFail("table 아님") }
        XCTAssertEqual(table.columnCount, 4)
        XCTAssertEqual(table.rows.count, 1)
        XCTAssertEqual(table.rows[0].map { String($0.characters) }, ["You", "대명사", "주어 S", "너는"])
    }

    func test_구분선_없는_파이프줄은_표가_아니라_문단으로_처리된다() {
        let blocks = MarkdownBlockParser.parse("| just | text |")

        XCTAssertEqual(blocks.count, 1)
        guard case let .paragraph(text) = blocks[0] else { return XCTFail("표로 오인되면 안 됨") }
        XCTAssertEqual(String(text.characters), "| just | text |")
    }

    func test_예문인용이_영문한국어_쌍으로_파싱된다() {
        let blocks = MarkdownBlockParser.parse("> **I love you.**\n> 나는 너를 사랑한다.")

        XCTAssertEqual(blocks.count, 1)
        guard case let .exampleQuote(english, korean) = blocks[0] else { return XCTFail("exampleQuote 아님") }
        XCTAssertEqual(String(english.characters), "I love you.")
        XCTAssertEqual(korean.map { String($0.characters) }, "나는 너를 사랑한다.")
    }

    func test_한국어_줄이_없는_예문인용도_파싱된다() {
        let blocks = MarkdownBlockParser.parse("> Just English.")

        guard case let .exampleQuote(english, korean) = blocks[0] else { return XCTFail("exampleQuote 아님") }
        XCTAssertEqual(String(english.characters), "Just English.")
        XCTAssertNil(korean)
    }

    func test_콜아웃_3종이_종류별로_파싱된다() {
        let key = MarkdownBlockParser.parse("> [!핵심] 제목1\n> 본문1")
        guard case let .callout(kind1, title1, body1) = key[0] else { return XCTFail("callout 아님") }
        XCTAssertEqual(kind1, .key)
        XCTAssertEqual(String(title1.characters), "제목1")
        XCTAssertEqual(body1.map { String($0.characters) }, ["본문1"])

        let caution = MarkdownBlockParser.parse("> [!주의] 제목2\n> 본문2-1\n> 본문2-2")
        guard case let .callout(kind2, _, body2) = caution[0] else { return XCTFail("callout 아님") }
        XCTAssertEqual(kind2, .caution)
        XCTAssertEqual(body2.map { String($0.characters) }, ["본문2-1", "본문2-2"])

        let tip = MarkdownBlockParser.parse("> [!팁] 제목3\n> 본문3")
        guard case let .callout(kind3, _, _) = tip[0] else { return XCTFail("callout 아님") }
        XCTAssertEqual(kind3, .tip)
    }

    func test_지원하지_않는_콜아웃_종류는_예문인용으로_폴백한다() {
        let blocks = MarkdownBlockParser.parse("> [!경고] 위험\n> 조심하세요")

        guard case let .exampleQuote(english, korean) = blocks[0] else {
            return XCTFail("콜아웃이 아니라 예문인용으로 폴백해야 함")
        }
        XCTAssertEqual(String(english.characters), "[!경고] 위험")
        XCTAssertEqual(korean.map { String($0.characters) }, "조심하세요")
    }

    func test_구조도식은_원문줄과_공백을_그대로_보존한다() {
        let markdown = "```structure\nYou   love   me.\n[주어 S]   [동사 V]   [목적어 O]\n```"
        let blocks = MarkdownBlockParser.parse(markdown)

        XCTAssertEqual(blocks.count, 1)
        guard case let .structure(title, lines) = blocks[0] else { return XCTFail("structure 아님") }
        XCTAssertEqual(title, "문장 구조")
        XCTAssertEqual(lines, ["You   love   me.", "[주어 S]   [동사 V]   [목적어 O]"])
    }

    func test_닫히지_않은_코드펜스는_EOF까지_수집하고_크래시_없이_끝난다() {
        let markdown = "```structure\n줄1\n줄2"
        let blocks = MarkdownBlockParser.parse(markdown)

        XCTAssertEqual(blocks.count, 1)
        guard case let .structure(_, lines) = blocks[0] else { return XCTFail("structure 아님") }
        XCTAssertEqual(lines, ["줄1", "줄2"])
    }

    func test_수평선이_파싱된다() {
        let blocks = MarkdownBlockParser.parse("문단\n\n---\n\n다음 문단")

        XCTAssertEqual(blocks.count, 3)
        guard case .paragraph = blocks[0] else { return XCTFail("paragraph 아님") }
        XCTAssertEqual(blocks[1], .divider)
        guard case .paragraph = blocks[2] else { return XCTFail("paragraph 아님") }
    }

    func test_전체_응답_예시가_기대한_블록_순서로_파싱된다() {
        let markdown = """
        ## 1. 문장 성분 쪼개기

        **You love me.** 는 3형식 문장이에요.

        | 단어 | 품사 |
        |---|---|
        | You | 대명사 |

        - ✗ You love I.
        - ✓ You love me.

        > [!핵심] 핵심 규칙
        > 조사 대신 형태를 씁니다.

        > **I love you.**
        > 나는 너를 사랑한다.

        ```structure
        You   love   me.
        [S]   [V]    [O]
        ```

        ---

        #### 한 줄 정리

        끝.
        """

        let blocks = MarkdownBlockParser.parse(markdown)

        XCTAssertEqual(blocks.map(kindLabel), [
            "heading", "paragraph", "table", "resultList",
            "callout", "exampleQuote", "structure", "divider", "heading", "paragraph"
        ])
    }

    private func kindLabel(_ block: MarkdownBlock) -> String {
        switch block {
        case .heading: "heading"
        case .paragraph: "paragraph"
        case .bulletList: "bulletList"
        case .orderedList: "orderedList"
        case .resultList: "resultList"
        case .table: "table"
        case .exampleQuote: "exampleQuote"
        case .callout: "callout"
        case .structure: "structure"
        case .divider: "divider"
        }
    }
}
