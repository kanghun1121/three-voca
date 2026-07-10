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
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .foregroundStyle(DesignSystemAsset.growDeep.swiftUIColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(DesignSystemAsset.growDeep.swiftUIColor.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 8))
            }
            navButton(label: "이전 달", systemImage: "chevron.left", action: onPrevious, isEnabled: true)
            navButton(label: "다음 달", systemImage: "chevron.right", action: onNext, isEnabled: !isAtCurrentMonth)
        }
    }

    private func navButton(label: String, systemImage: String, action: @escaping () -> Void, isEnabled: Bool) -> some View {
        Button(label, systemImage: systemImage, action: action)
            .labelStyle(.iconOnly)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(
                isEnabled
                    ? DesignSystemAsset.fgMuted.swiftUIColor
                    : DesignSystemAsset.fgSubtle.swiftUIColor
            )
            .frame(width: 30, height: 30)
            .background(DesignSystemAsset.bgSubtle.swiftUIColor)
            .clipShape(.rect(cornerRadius: 9))
            .contentShape(Rectangle())
            .disabled(!isEnabled)
    }
}
