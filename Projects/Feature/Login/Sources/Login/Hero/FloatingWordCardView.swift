import SwiftUI

import DesignSystem

struct FloatingWordCardView: View {
    let word: String
    let meaning: String
    let tagKind: WordCardTagPillView.Kind

    @ScaledMetric private var meaningSize: CGFloat = DesignSystemTypography.Pretendard.regular12.size

    private let cardBaseColor = DesignSystemColor.Foreground.strong

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FloatingWordCardHeaderView(word: word, tagKind: tagKind)
                .padding(.bottom, 4)
            Text(meaning)
                .typography(DesignSystemTypography.Pretendard.regular12.scaled(to: CGFloat(meaningSize)))
                .foregroundStyle(DesignSystemColor.Foreground.muted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(width: 220)
        .background(DesignSystemColor.Background.base)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(
            color: cardBaseColor.opacity(0.12),
            radius: 16,
            x: 0,
            y: 12
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(cardBaseColor.opacity(0.04), lineWidth: 1)
        }
    }
}
