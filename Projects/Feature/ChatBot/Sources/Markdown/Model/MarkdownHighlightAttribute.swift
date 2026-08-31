import Foundation

/// `==하이라이트==` 문법을 표시하는 커스텀 AttributedString 속성.
/// Foundation이 기본 제공하는 `.inlinePresentationIntent`/`.link`와 같은 run에 공존시켜,
/// 스타일러가 run 하나를 순회하며 모든 인라인 서식을 한 번에 판단할 수 있게 한다.
enum MarkdownHighlightAttribute: AttributedStringKey {
    typealias Value = Bool
    static let name = "markdownHighlight"
}

extension AttributeScopes {
    struct MarkdownAttributeScope: AttributeScope {
        let markdownHighlight: MarkdownHighlightAttribute
        let markdownTailOpacity: MarkdownTailOpacityAttribute
    }

    var markdown: MarkdownAttributeScope.Type { MarkdownAttributeScope.self }
}

extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(
        dynamicMember keyPath: KeyPath<AttributeScopes.MarkdownAttributeScope, T>
    ) -> T {
        self[T.self]
    }
}
