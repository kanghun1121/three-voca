import Foundation

/// 인라인 서식 5종(`**굵게**`/`*기울임*`/`` `코드` ``/`==하이라이트==`/`[텍스트](url)`)을
/// `AttributedString`으로 파싱한다. `==하이라이트==`는 Foundation이 모르는 비표준 문법이라
/// 직접 전처리로 세그먼트를 나눈 뒤, 각 세그먼트를 `AttributedString(markdown:)`에 위임한다.
///
/// 이 단계 결과에는 의미 속성(`.inlinePresentationIntent`/`.link`/`markdownHighlight`)만
/// 담기고 폰트·색 같은 디자인 값은 없다 — DesignSystem 의존 없이 순수 함수로 테스트 가능하다.
/// 디자인 토큰 적용은 `MarkdownInlineStyler`가 별도로 담당한다.
enum MarkdownInlineParser {
    private static let parseOptions = AttributedString.MarkdownParsingOptions(
        allowsExtendedAttributes: true,
        interpretedSyntax: .inlineOnlyPreservingWhitespace,
        failurePolicy: .returnPartiallyParsedIfPossible
    )

    static func parse(_ raw: String) -> AttributedString {
        var result = AttributedString()
        for segment in splitHighlightSegments(raw) {
            var parsed = parseInlineMarkdown(segment.text)
            if segment.isHighlighted {
                parsed.markdownHighlight = true
            }
            result += parsed
        }
        return result
    }

    private static func parseInlineMarkdown(_ text: String) -> AttributedString {
        guard let parsed = try? AttributedString(markdown: text, options: parseOptions) else {
            return AttributedString(text)
        }
        return parsed
    }

    private struct HighlightSegment {
        let text: String
        let isHighlighted: Bool
    }

    /// `==...==` 쌍을 찾아 하이라이트 여부가 다른 세그먼트로 나눈다.
    /// 짝이 맞지 않는 `==`는 일반 텍스트로 남긴다.
    private static func splitHighlightSegments(_ raw: String) -> [HighlightSegment] {
        var segments: [HighlightSegment] = []
        var plain = ""
        var remaining = Substring(raw)

        while let openRange = remaining.range(of: "==") {
            let afterOpen = remaining[openRange.upperBound...]
            guard let closeRange = afterOpen.range(of: "=="), !afterOpen[afterOpen.startIndex..<closeRange.lowerBound].isEmpty else {
                break
            }

            plain += remaining[remaining.startIndex..<openRange.lowerBound]
            if !plain.isEmpty {
                segments.append(HighlightSegment(text: plain, isHighlighted: false))
                plain = ""
            }

            let highlighted = String(afterOpen[afterOpen.startIndex..<closeRange.lowerBound])
            segments.append(HighlightSegment(text: highlighted, isHighlighted: true))

            remaining = remaining[closeRange.upperBound...]
        }

        plain += remaining
        if !plain.isEmpty {
            segments.append(HighlightSegment(text: plain, isHighlighted: false))
        }

        return segments
    }
}
