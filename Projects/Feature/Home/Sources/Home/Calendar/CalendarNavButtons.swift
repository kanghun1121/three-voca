import SwiftUI

import DesignSystem

struct CalendarNavButtons: View {
    let isAtCurrentMonth: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            if !isAtCurrentMonth {
                Button("오늘로", action: onToday)
                    .typography(DesignSystemTypography.Pretendard.semiBold12)
                    .foregroundStyle(DesignSystemColor.Accent.selectedBlueText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(DesignSystemColor.Accent.selectedBlue.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 8))
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
            makeNavButton(
                label: "이전 달",
                systemImage: "chevron.left",
                action: onPrevious,
                isEnabled: true
            )
            makeNavButton(
                label: "다음 달",
                systemImage: "chevron.right",
                action: onNext,
                isEnabled: !isAtCurrentMonth
            )
        }
    }

    private func makeNavButton(
        label: String,
        systemImage: String,
        action: @escaping () -> Void,
        isEnabled: Bool
    ) -> some View {
        Button(label, systemImage: systemImage, action: action)
            .labelStyle(.iconOnly)
            .typography(DesignSystemTypography.Pretendard.semiBold14)
            .foregroundStyle(
                isEnabled
                    ? DesignSystemColor.Foreground.muted
                    : DesignSystemColor.Foreground.subtle
            )
            .frame(width: 26, height: 26)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .disabled(!isEnabled)
    }
}
