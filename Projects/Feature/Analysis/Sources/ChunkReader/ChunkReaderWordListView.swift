import SwiftUI

import DesignSystem

struct ChunkReaderWordListView: View {
    let words: [ChunkReaderPresentationModel.WordRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .background(DesignSystemAsset.borderSubtle.swiftUIColor)
                .padding(.bottom, 10)

            Text("단어 뜻")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .padding(.bottom, 4)

            ChunkReaderWordRows(words: words)
        }
    }
}
