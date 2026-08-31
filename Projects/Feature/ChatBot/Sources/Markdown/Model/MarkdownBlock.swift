import Foundation

/// 챗봇 응답 마크다운 부분집합의 최상위 블록. 인라인 서식(굵게/기울임/코드/하이라이트/링크)은
/// 이미 파싱이 끝난 `AttributedString`으로 담겨 있다 — 렌더 시점마다 다시 파싱하지 않는다.
/// `structure`만 예외로 원문 줄을 그대로 보존한다(모노스페이스 정렬·공백 유지 목적).
enum MarkdownBlock: Equatable {
    case heading(level: Int, text: AttributedString)
    case paragraph(AttributedString)
    case bulletList([MarkdownListItem])
    case orderedList([MarkdownListItem])
    case resultList([MarkdownResultItem])
    case table(MarkdownTable)
    case exampleQuote(english: AttributedString, korean: AttributedString?)
    case callout(kind: MarkdownCalloutKind, title: AttributedString, body: [AttributedString])
    case structure(title: String, lines: [String])
    case divider
}
