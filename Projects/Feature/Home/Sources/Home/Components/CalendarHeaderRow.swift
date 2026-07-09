import SwiftUI

import DesignSystem

struct CalendarHeaderRow: View {
    let year: Int
    let month: Int
    let isAtCurrentMonth: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            HStack(alignment: .lastTextBaseline, spacing: 7) {
                Text("\(String(month))월")
                    .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 19))
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                Text(String(year))
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                    .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            }
            Spacer()
            CalendarNavButtons(
                isAtCurrentMonth: isAtCurrentMonth,
                onPrevious: onPrevious,
                onNext: onNext,
                onToday: onToday
            )
        }
    }
}
