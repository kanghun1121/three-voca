import SwiftUI

struct MarkdownResultListView: View {
    let items: [MarkdownResultItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                MarkdownResultRowView(item: item)
            }
        }
    }
}
