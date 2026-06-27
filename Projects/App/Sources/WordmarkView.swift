import SwiftUI

import DesignSystem

struct WordmarkView: View {
    var body: some View {
        VStack(spacing: 22) {
            Text("DAILY VOCABULARY")
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                .tracking(3.6)
                .foregroundStyle(DesignSystemAsset.primary.swiftUIColor.opacity(0.55))

            HStack(spacing: 0) {
                Text("쓰리")
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                Text("보카")
                    .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
            }
            .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 60))
            .tracking(-2.7)
        }
        .multilineTextAlignment(.center)
    }
}
