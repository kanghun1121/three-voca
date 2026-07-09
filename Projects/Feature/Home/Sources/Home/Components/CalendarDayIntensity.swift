import SwiftUI

import DesignSystem

enum CalendarDayIntensity {
    case lv0, lv1, lv2, lv3

    var background: Color {
        switch self {
        case .lv0: DesignSystemAsset.calendarLight.swiftUIColor
        case .lv1: DesignSystemAsset.calendarMid.swiftUIColor
        case .lv2: DesignSystemAsset.positive.swiftUIColor.opacity(0.62)
        case .lv3: DesignSystemAsset.positive.swiftUIColor
        }
    }

    var textColor: Color {
        switch self {
        case .lv0, .lv1: DesignSystemAsset.positive.swiftUIColor
        case .lv2, .lv3: DesignSystemAsset.white.swiftUIColor
        }
    }
}
