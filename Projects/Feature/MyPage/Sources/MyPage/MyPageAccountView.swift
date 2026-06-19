import SwiftUI

import DesignSystem

struct MyPageAccountView: View {
    let email: String

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("로그인 계정")
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
                    .kerning(12 * 0.04)

                Text(email)
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                    .kerning(18 * -0.015)
                    .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 26)
            .padding(.bottom, 26)

            Rectangle()
                .fill(DesignSystemAsset.border.swiftUIColor)
                .frame(height: 1)
                .padding(.horizontal, 26)
        }
    }
}
