import Foundation

extension MarkdownBlock {
    /// 이 블록의 "마지막 텍스트"에만 `transform`을 적용한 새 블록을 반환한다.
    /// 어떤 텍스트가 마지막인지는 블록 형태에 달린 지식이라 여기(모델)에 둔다 — 페이드 커브 같은
    /// 연출 정책은 이 함수를 호출하는 쪽(`MarkdownTailFader`)의 책임으로 분리한다.
    /// `.table`/`.structure`/`.divider`는 심을 대상 텍스트가 없어 원본을 그대로 반환한다.
    func replacingTailText(_ transform: (AttributedString) -> AttributedString) -> MarkdownBlock {
        switch self {
        case let .heading(level, text):
            return .heading(level: level, text: transform(text))

        case let .paragraph(text):
            return .paragraph(transform(text))

        case let .bulletList(items):
            return .bulletList(replacingLastText(of: items, transform))

        case let .orderedList(items):
            return .orderedList(replacingLastText(of: items, transform))

        case let .resultList(items):
            guard let last = items.last else { return self }
            var updated = items
            updated[updated.count - 1] = MarkdownResultItem(kind: last.kind, text: transform(last.text))
            return .resultList(updated)

        case let .exampleQuote(english, korean):
            if let korean {
                return .exampleQuote(english: english, korean: transform(korean))
            }
            return .exampleQuote(english: transform(english), korean: nil)

        case let .callout(kind, title, body):
            guard let lastLine = body.last else {
                return .callout(kind: kind, title: transform(title), body: body)
            }
            var updatedBody = body
            updatedBody[updatedBody.count - 1] = transform(lastLine)
            return .callout(kind: kind, title: title, body: updatedBody)

        case .table, .structure, .divider:
            return self
        }
    }

    private func replacingLastText(
        of items: [MarkdownListItem],
        _ transform: (AttributedString) -> AttributedString
    ) -> [MarkdownListItem] {
        guard let last = items.last else { return items }
        var updated = items
        updated[updated.count - 1] = MarkdownListItem(text: transform(last.text), depth: last.depth)
        return updated
    }
}
