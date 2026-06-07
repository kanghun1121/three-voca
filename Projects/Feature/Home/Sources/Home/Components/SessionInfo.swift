import SwiftUI

import DesignSystem

struct SessionInfo: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            Text(subtitle)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
        }
    }
}
