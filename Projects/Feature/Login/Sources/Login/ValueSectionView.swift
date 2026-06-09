import SwiftUI

import DesignSystem

struct ValueSectionView: View {
    var body: some View {
        VStack(spacing: 0) {
            headlineText
            subheadText
                .padding(.top, 14)
            Spacer()
        }
        .multilineTextAlignment(.center)
    }

    private var headlineText: some View {
        (Text("단어를 ")
        + Text("3초 안에")
            .foregroundStyle(DesignSystemAsset.game.swiftUIColor)
        + Text("\n떠올리는 힘"))
        .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 32))
        .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
        .kerning(32 * -0.025)
    }

    private var subheadText: some View {
        Text("시간 압박이 진짜 아는 단어를 가려냅니다.\n1,200개 어휘를 게임처럼 익혀보세요.")
            .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
            .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            .lineSpacing(8)
    }
}
