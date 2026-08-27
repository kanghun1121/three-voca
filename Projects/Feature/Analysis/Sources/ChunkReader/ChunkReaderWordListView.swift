import SwiftUI

import DesignSystem
import DomainInterface

struct ChunkReaderWordListView: View {
    let words: [Indexed<WordDetail.Example.Word>]

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
