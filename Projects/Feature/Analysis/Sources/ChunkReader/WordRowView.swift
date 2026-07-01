import SwiftUI

import DesignSystem

struct WordRowView: View {
    let word: ChunkReaderPresentationModel.WordRow

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(word.word)
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 16))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .frame(minWidth: 70, alignment: .leading)

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
