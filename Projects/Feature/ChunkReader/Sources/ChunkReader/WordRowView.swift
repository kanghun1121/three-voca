import SwiftUI

import DesignSystem
import DomainInterface

struct WordRowView: View {
    let wordAnnotation: Indexed<WordDetail.Example.WordAnnotation>

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 14) {
            Text(wordAnnotation.element.word)
                .typography(DesignSystemTypography.Pretendard.extraBold17)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
                .frame(minWidth: 98, alignment: .leading)

            Text(wordAnnotation.element.meaning)
                .typography(DesignSystemTypography.Pretendard.medium15)
                .foregroundStyle(DesignSystemColor.Foreground.default)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(wordAnnotation.element.pos.koreanPartOfSpeechLabel)
                .typography(DesignSystemTypography.Pretendard.bold11_5)
                .foregroundStyle(DesignSystemColor.Accent.selectedBlueText)
                .padding(.horizontal, 11)
                .padding(.vertical, 5)
                .background(DesignSystemColor.Accent.selectedBlue100)
                .clipShape(.capsule)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 2)
    }
}
