import SwiftUI

import DesignSystem
import DomainInterface

struct ChunkReaderWordRows: View {
    let words: [Indexed<WordDetail.Example.Word>]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(words) { word in
                if word.id > 0 {
                    Divider()
                        .background(DesignSystemAsset.borderSubtle.swiftUIColor)
                }
                WordRowView(word: word)
            }
        }
    }
}
