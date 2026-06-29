import SwiftUI

import DesignSystem

enum CalendarDayIntensity {
    case light, mid, full

    var color: Color {
        switch self {
        case .light: DesignSystemAsset.calendarLight.swiftUIColor
        case .mid:   DesignSystemAsset.calendarMid.swiftUIColor
        case .full:  DesignSystemAsset.primary.swiftUIColor
        }
    }
}
