import SwiftUI

import DesignSystem

enum CalendarDayIntensity {
    case lv0, lv1, lv2, lv3

    var background: Color {
        switch self {
        case .lv0: DesignSystemAsset.heatmap0.swiftUIColor
        case .lv1: DesignSystemAsset.heatmap1.swiftUIColor
        case .lv2: DesignSystemAsset.heatmap2.swiftUIColor
        case .lv3: DesignSystemAsset.heatmap3.swiftUIColor
        }
    }

    var textColor: Color {
        switch self {
        case .lv0, .lv1: DesignSystemAsset.growDeep.swiftUIColor
        case .lv2, .lv3: DesignSystemAsset.white.swiftUIColor
        }
    }
}
