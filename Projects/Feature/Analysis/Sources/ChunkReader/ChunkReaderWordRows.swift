import SwiftUI

import DesignSystem

struct ChunkReaderWordRows: View {
    let words: [ChunkReaderPresentationModel.WordRow]

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
