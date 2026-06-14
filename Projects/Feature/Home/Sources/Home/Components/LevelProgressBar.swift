import SwiftUI

import DesignSystem

struct LevelProgressBar: View {
    let progressRatio: Double
    let status: LevelStatus

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(DesignSystemAsset.progressTrack.swiftUIColor)
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    status == .notStarted
                        ? DesignSystemAsset.fgMuted.swiftUIColor.opacity(0.3)
                        : DesignSystemAsset.primary.swiftUIColor
                )
                .scaleEffect(
                    x: max(0, min(1, progressRatio)),
                    anchor: .leading
                )
        }
        .frame(height: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}
