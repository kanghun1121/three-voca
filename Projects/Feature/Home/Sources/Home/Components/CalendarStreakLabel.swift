import SwiftUI

import DesignSystem

struct CalendarStreakLabel: View {
    let streakDays: Int

    var body: some View {
        HStack(spacing: 5) {
            DesignSystemAsset.flame.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
            Text("\(streakDays)일 연속")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
                .foregroundStyle(DesignSystemAsset.streakOrange.swiftUIColor)
        }
    }
}
