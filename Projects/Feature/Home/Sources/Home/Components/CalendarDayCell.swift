import SwiftUI

import DesignSystem

enum CalendarDayIntensity {
    case light, mid, full

    var color: Color {
        switch self {
        case .light: HomeColors.calendarLight
        case .mid:   HomeColors.calendarMid
        case .full:  DesignSystemAsset.primary.swiftUIColor
        }
    }
}

enum CalendarDayCellKind {
    case empty
    case future(Int)
    case studied(Int, CalendarDayIntensity)
    case notStudied(Int)
    case today(Int, CalendarDayIntensity?)
}

struct CalendarDayCell: View {
    let kind: CalendarDayCellKind

    var body: some View {
        Group {
            switch kind {
            case .empty:
                Color.clear
                    .frame(width: 28, height: 28)

            case .future(let day):
                Text("\(day)")
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor.opacity(0.45))
                    .frame(width: 28, height: 28)

            case .studied(let day, let intensity):
                ZStack {
                    Circle()
                        .fill(intensity.color)
                    Text("\(day)")
                        .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                }
                .frame(width: 28, height: 28)

            case .notStudied(let day):
                Text("\(day)")
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                    .monospacedDigit()
                    .frame(width: 28, height: 28)

            case .today(let day, let intensity):
                ZStack {
                    if let intensity {
                        Circle()
                            .fill(intensity.color)
                    }
                    Text("\(day)")
                        .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
                        .foregroundStyle(intensity != nil ? .white : DesignSystemAsset.fgStrong.swiftUIColor)
                        .monospacedDigit()
                }
                .frame(width: 28, height: 28)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
