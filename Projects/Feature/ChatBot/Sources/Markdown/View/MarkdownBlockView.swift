import SwiftUI

/// 블록 종류에 맞는 구체 뷰를 고른다. `AnyView`를 쓰지 않도록 `@ViewBuilder` + `switch`로
/// 처리한다(docs/FRONTEND.md).
///
/// 블록 사이 세로 여백은 `MarkdownView`의 `VStack.spacing`이 아니라 여기서 상하 5pt씩 주는
/// 방식으로 준다 — 인접 블록끼리 5+5=10pt 간격이 되고, 리스트 안 항목 사이처럼 블록 내부
/// 여백과 블록 사이 여백을 서로 다른 값으로 독립 조정할 수 있다.
struct MarkdownBlockView: View {
    let block: MarkdownBlock

    var body: some View {
        // 구분선은 화면에 그리지 않는다 — 여백(패딩)도 함께 생략해 빈 줄로 남지 않게 한다.
        if case .divider = block {
            EmptyView()
        } else {
            content
                .padding(.vertical, 15)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch block {
        case let .heading(level, text):
            MarkdownHeadingView(level: level, text: text)
        case let .paragraph(text):
            MarkdownParagraphView(text: text)
        case let .bulletList(items):
            MarkdownBulletListView(items: items)
        case let .orderedList(items):
            MarkdownOrderedListView(items: items)
        case let .resultList(items):
            MarkdownResultListView(items: items)
        case let .table(table):
            MarkdownTableView(table: table)
        case let .exampleQuote(english, korean):
            MarkdownExampleQuoteView(english: english, korean: korean)
        case let .callout(kind, title, body):
            MarkdownCalloutView(kind: kind, title: title, body: body)
        case let .structure(title, lines):
            MarkdownStructureView(title: title, lines: lines)
        case .divider:
            EmptyView()
        }
    }
}
