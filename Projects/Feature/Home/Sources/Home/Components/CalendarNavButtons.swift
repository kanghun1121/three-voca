import SwiftUI

import DesignSystem

struct CalendarNavButtons: View {
    let isAtCurrentMonth: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            if !isAtCurrentMonth {
                Button("오늘로", action: onToday)
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(DesignSystemAsset.primary.swiftUIColor.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 8))
            }
            Button("이전 달", systemImage: "chevron.left", action: onPrevious)
                .labelStyle(.iconOnly)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .frame(width: 44, height: 44)
            Button("다음 달", systemImage: "chevron.right", action: onNext)
                .labelStyle(.iconOnly)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(
                    isAtCurrentMonth
                        ? DesignSystemAsset.fgMuted.swiftUIColor
                        : DesignSystemAsset.fgStrong.swiftUIColor
                )
                .frame(width: 44, height: 44)
                .disabled(isAtCurrentMonth)
        }
    }
}
