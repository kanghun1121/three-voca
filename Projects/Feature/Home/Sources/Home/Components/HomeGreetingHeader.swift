import SwiftUI

import DesignSystem

struct HomeGreetingHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("오늘도 가볍게")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            Text("3초 안에 떠올려볼까요?")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 25))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .tracking(-0.55)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
        .padding(.horizontal, 22)
        .padding(.bottom, 18)
    }
}
