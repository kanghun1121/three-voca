import SwiftUI

import DesignSystem

struct CalendarHeaderRow: View {
    let year: Int
    let month: Int
    let isAtCurrentMonth: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text("\(String(year))년 \(String(month))월")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 15.5))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            Spacer()
            CalendarNavButtons(
                isAtCurrentMonth: isAtCurrentMonth,
                onPrevious: onPrevious,
                onNext: onNext
            )
        }
    }
}
