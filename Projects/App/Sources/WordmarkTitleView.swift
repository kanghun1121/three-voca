import SwiftUI

import DesignSystem

struct WordmarkTitleView: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("쓰리")
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            Text("보카")
                .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
        }
        .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 60))
        .tracking(-2.7)
    }
}
