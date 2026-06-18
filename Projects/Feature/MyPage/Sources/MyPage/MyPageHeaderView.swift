import SwiftUI

import DesignSystem

struct MyPageHeaderView: View {
    var body: some View {
        Text("마이페이지")
            .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 26))
            .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            .kerning(26 * -0.024)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
            .padding(.horizontal, 26)
            .padding(.bottom, 30)
    }
}
