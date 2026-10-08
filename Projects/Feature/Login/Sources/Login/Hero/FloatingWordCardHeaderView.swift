import SwiftUI

import DesignSystem

struct FloatingWordCardHeaderView: View {
    @ScaledMetric private var wordSize: CGFloat = DesignSystemTypography.Pretendard.extraBold18.size

    let word: String
    let tagKind: WordCardTagPillView.Kind

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(word)
                .typography(DesignSystemTypography.Pretendard.extraBold18.scaled(to: CGFloat(wordSize)))
                .foregroundStyle(DesignSystemColor.Foreground.strong)
            Spacer()
            WordCardTagPillView(kind: tagKind)
        }
    }
}
