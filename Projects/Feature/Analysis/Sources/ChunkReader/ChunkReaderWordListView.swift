import SwiftUI

import DesignSystem

struct ChunkReaderWordListView: View {
    let words: [ChunkReaderPresentationModel.WordRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("단어 뜻")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            ChunkReaderWordRows(words: words)
        }
    }
}
