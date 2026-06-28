import SwiftUI

import DesignSystem

struct CalendarFooterRow: View {
    let streakDays: Int
    let isAtCurrentMonth: Bool
    let onToday: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            if streakDays > 0 && isAtCurrentMonth {
                HStack(spacing: 5) {
                    DesignSystemAsset.flame.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                    Text("\(streakDays)일 연속")
                        .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
                        .foregroundStyle(HomeColors.streakOrange)
                }
            }
            Spacer()
            if !isAtCurrentMonth {
                Button("오늘로", action: onToday)
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DesignSystemAsset.primary.swiftUIColor.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 8))
            }
        }
    }
}
