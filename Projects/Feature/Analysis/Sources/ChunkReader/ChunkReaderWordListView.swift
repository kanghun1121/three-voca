import SwiftUI

import DesignSystem

struct ChunkReaderWordListView: View {
    let words: [ChunkReaderPresentationModel.WordRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .background(DesignSystemAsset.borderSubtle.swiftUIColor)
                .padding(.bottom, 15)

            ChunkReaderBadge(icon: "text.book.closed.fill", label: "단어 뜻")
                .padding(.bottom, 8)

            ChunkReaderWordRows(words: words)
        }
    }
}
