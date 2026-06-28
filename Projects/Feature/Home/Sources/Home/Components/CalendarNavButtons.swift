import SwiftUI

import DesignSystem

struct CalendarNavButtons: View {
    let isAtCurrentMonth: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 2) {
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
