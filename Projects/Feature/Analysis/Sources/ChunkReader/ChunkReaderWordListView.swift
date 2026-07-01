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
                ForEach(Array(words.enumerated()), id: \.element.id) { index, word in
                    if index > 0 {
                        Divider()
                            .background(DesignSystemAsset.borderSubtle.swiftUIColor)
                    }
                    WordRowView(word: word)
                }
            }
        }
    }
}

private struct WordRowView: View {
    let word: ChunkReaderPresentationModel.WordRow

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(word.word)
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 16))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .frame(width: 88, alignment: .leading)

            Text(word.meaning)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                .foregroundStyle(DesignSystemAsset.fg.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(word.partOfSpeech)
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 11))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(DesignSystemAsset.bgSubtle.swiftUIColor)
                .clipShape(.capsule)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 2)
    }
}
