import SwiftUI

import DesignSystem

struct CalendarDayCell: View {
    let kind: CalendarDayCellKind

    var body: some View {
        content
            .aspectRatio(1, contentMode: .fit)
            .scaleEffect(0.88)
    }

    @ViewBuilder
    private var content: some View {
        switch kind {
        case .empty:
            Color.clear

        case .future(let day):
            dayLabel(day, color: DesignSystemAsset.fgSubtle.swiftUIColor, weight: DesignSystemFontFamily.Pretendard.semiBold)

        case .notStudied(let day):
            dayLabel(day, color: DesignSystemAsset.fgMuted.swiftUIColor, weight: DesignSystemFontFamily.Pretendard.semiBold)

        case .studied(let day, let intensity):
            RoundedRectangle(cornerRadius: 11)
                .fill(intensity.background)
                .overlay { dayLabel(day, color: intensity.textColor, weight: DesignSystemFontFamily.Pretendard.extraBold) }

        case .today(let day, let intensity):
            RoundedRectangle(cornerRadius: 11)
                .fill(intensity?.background ?? .clear)
                .overlay {
                    RoundedRectangle(cornerRadius: 11)
                        .strokeBorder(DesignSystemAsset.growDeep.swiftUIColor, lineWidth: 2.5)
                }
                .overlay {
                    dayLabel(
                        day,
                        color: intensity?.textColor ?? DesignSystemAsset.growDeep.swiftUIColor,
                        weight: DesignSystemFontFamily.Pretendard.extraBold
                    )
                }
        }
    }

    private func dayLabel(_ day: Int, color: Color, weight: DesignSystemFontConvertible) -> some View {
        Text("\(day)")
            .font(weight.swiftUIFont(size: 12.5))
            .foregroundStyle(color)
            .monospacedDigit()
    }
}
