import SwiftUI

import DesignSystem

struct HomeLoadingView: View {
    var body: some View {
        VStack(spacing: 22) {
            ProgressView()
                .tint(DesignSystemAsset.primary.swiftUIColor)
            Text("학습 기록을 불러오는 중")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 13.5))
                .tracking(-0.0675)
                .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystemAsset.bg.swiftUIColor)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("학습 기록을 불러오는 중")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    HomeLoadingView()
}
