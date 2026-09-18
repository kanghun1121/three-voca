import SwiftUI

import DesignSystem
import DomainInterface

struct WordRowView: View {
    let wordAnnotation: Indexed<WordDetail.Example.WordAnnotation>

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 14) {
            Text(wordAnnotation.element.word)
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 17))
                .tracking(-0.02 * 17)
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .frame(minWidth: 98, alignment: .leading)

            Text(wordAnnotation.element.meaning)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                .tracking(-0.01 * 15)
                .foregroundStyle(DesignSystemAsset.fg.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(wordAnnotation.element.pos.koreanPartOfSpeechLabel)
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 11.5))
                .tracking(-0.01 * 11.5)
                .foregroundStyle(DesignSystemAsset.selectedBlue.swiftUIColor)
                .padding(.horizontal, 11)
                .padding(.vertical, 5)
                .background(DesignSystemAsset.selectedBlue100.swiftUIColor)
                .clipShape(.capsule)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 2)
    }
}
