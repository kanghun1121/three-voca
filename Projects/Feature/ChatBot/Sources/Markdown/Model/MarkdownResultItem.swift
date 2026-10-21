import Foundation

/// 정답·오답 대조 리스트(`- ✓ ...` / `- ✗ ...`) 한 항목.
struct MarkdownResultItem: Equatable {
    enum Kind: Equatable {
        case correct
        case incorrect
    }

    let kind: Kind
    let text: AttributedString
}
