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
