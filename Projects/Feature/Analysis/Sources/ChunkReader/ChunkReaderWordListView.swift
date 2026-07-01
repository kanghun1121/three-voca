import SwiftUI

import DesignSystem

struct ChunkReaderWordListView: View {
    let words: [ChunkReaderPresentationModel.WordRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("단어 뜻")
                    .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 14))
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                Text("문장 등장 순서")
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
            }

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
}
