import SwiftUI

import DesignSystem

struct SessionCircleBadge: View {
    let sessionNumber: Int
    let isCompleted: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    isCompleted
                        ? DesignSystemAsset.positive.swiftUIColor
                        : DesignSystemAsset.progressTrack.swiftUIColor
                )
                .frame(width: 26, height: 26)
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                    .accessibilityHidden(true)
            } else {
                Text("\(sessionNumber)")
                    .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
                    .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            }
        }
        .accessibilityHidden(true)
    }
}
