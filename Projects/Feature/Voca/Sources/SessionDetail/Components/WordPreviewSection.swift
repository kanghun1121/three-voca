import SwiftUI

struct WordPreviewSection: View {
    let title: String
    let items: [SessionDetailViewState.WordPreview]
    let moreText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)

            ForEach(items) { item in
                WordPreviewRow(item: item)
            }

            if let moreText {
                Text(moreText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
            }
        }
    }
}

private struct WordPreviewRow: View {
    let item: SessionDetailViewState.WordPreview

    var body: some View {
        VStack(spacing: 0) {
            WordPreviewRowContent(item: item)
            Divider()
        }
    }
}

private struct WordPreviewRowContent: View {
    let item: SessionDetailViewState.WordPreview

    var body: some View {
        HStack {
            Text(item.term)
                .font(.body)
            Spacer()
            Text(item.primaryMeaning)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
    }
}
