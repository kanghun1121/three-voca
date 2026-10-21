import SwiftUI

import DesignSystem

struct CalendarHeaderRow: View {
    let title: String
    let isAtCurrentMonth: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .typography(DesignSystemTypography.Home.monthHeader)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
            Spacer()
            CalendarNavButtons(
                isAtCurrentMonth: isAtCurrentMonth,
                onPrevious: onPrevious,
                onNext: onNext,
                onToday: onToday
            )
        }
        .frame(minHeight: 44)
    }
}
