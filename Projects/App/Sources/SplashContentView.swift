import SwiftUI

import DesignSystem

struct SplashContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            DesignSystemAsset.splashBook.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 188, height: 213.6)
                .accessibilityHidden(true)

            Text("3초 단어")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 40))
                .kerning(-1.8)
                .foregroundStyle(DesignSystemAsset.growDeep.swiftUIColor)
                .padding(.top, 36)

            Text("한 장씩, 한 단어씩")
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                .kerning(-0.15)
                .foregroundStyle(DesignSystemAsset.growDeep.swiftUIColor.opacity(0.66))
                .padding(.top, 12)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
