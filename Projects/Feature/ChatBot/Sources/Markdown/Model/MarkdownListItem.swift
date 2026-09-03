import Foundation

/// 불릿/번호 리스트 한 항목. `depth`는 들여쓰기 단계(0 = 최상위, 1 = 중첩)다.
struct MarkdownListItem: Equatable {
    let text: AttributedString
    let depth: Int
}
