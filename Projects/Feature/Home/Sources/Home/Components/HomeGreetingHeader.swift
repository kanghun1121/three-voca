import SwiftUI

import DesignSystem

struct HomeGreetingHeader: View {
    let streakDays: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("오늘도 가볍게")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            Text("3초 안에 떠올려볼까요?")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 25))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .tracking(-0.55)
            if streakDays > 0 {
                streakChip
                    .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
        .padding(.horizontal, 22)
        .padding(.bottom, 18)
    }

    private var streakChip: some View {
        HStack(spacing: 4) {
            Text("🔥")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
            Text("\(streakDays)일 연속 학습 중")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
                .foregroundStyle(HomeColors.streakOrange)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(HomeColors.streakBg)
        .clipShape(.rect(cornerRadius: 100))
    }
}
