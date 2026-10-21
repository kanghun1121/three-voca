import SwiftUI

import DesignSystem

struct SplashContentView: View {
    private let markSize: CGFloat = 156
    private let markCornerRadiusRatio: CGFloat = 0.2237

    var body: some View {
        VStack(spacing: 0) {
            DesignSystemAsset.splashMark.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: markSize, height: markSize)
                .clipShape(RoundedRectangle(cornerRadius: markSize * markCornerRadiusRatio, style: .continuous))
                .accessibilityHidden(true)

            Text("3초 단어")
                .typography(DesignSystemTypography.Pretendard.extraBold30)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
                .padding(.top, 15)

            Text("하루 3초, 단어 한 입")
                .typography(DesignSystemTypography.Pretendard.semiBold15)
                .foregroundStyle(DesignSystemColor.Foreground.muted.opacity(0.66))
                .padding(.top, 12)
        }
        .padding(.horizontal, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
