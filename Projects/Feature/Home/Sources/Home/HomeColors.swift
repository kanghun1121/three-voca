import SwiftUI
import UIKit

import FeatureHomeInterface

enum HomeColors {
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let progressTrack  = Color(.systemGray5)
    static let emptyRingStroke = Color(.systemGray3)

    static let brandGreen  = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let brandOrange = Color(red: 1.00, green: 0.45, blue: 0.18)

    static func badgeBackground(_ level: LevelBadgeColor) -> Color {
        switch level {
        case .level1:
            return .dynamic(
                light: UIColor(red: 0.91, green: 0.96, blue: 0.91, alpha: 1),
                dark:  UIColor(red: 0.12, green: 0.22, blue: 0.13, alpha: 1)
            )
        case .level2, .level3:
            return .dynamic(
                light: UIColor(red: 0.89, green: 0.95, blue: 1.00, alpha: 1),
                dark:  UIColor(red: 0.10, green: 0.18, blue: 0.30, alpha: 1)
            )
        case .level4:
            return .dynamic(
                light: UIColor(red: 0.94, green: 0.89, blue: 1.00, alpha: 1),
                dark:  UIColor(red: 0.22, green: 0.13, blue: 0.32, alpha: 1)
            )
        case .unknown:
            return .gray.opacity(0.15)
        }
    }

    static func badgeForeground(_ level: LevelBadgeColor) -> Color {
        switch level {
        case .level1:
            return .dynamic(
                light: UIColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1),
                dark:  UIColor(red: 0.55, green: 0.85, blue: 0.55, alpha: 1)
            )
        case .level2, .level3:
            return .dynamic(
                light: UIColor(red: 0.08, green: 0.40, blue: 0.75, alpha: 1),
                dark:  UIColor(red: 0.55, green: 0.78, blue: 1.00, alpha: 1)
            )
        case .level4:
            return .dynamic(
                light: UIColor(red: 0.45, green: 0.18, blue: 0.72, alpha: 1),
                dark:  UIColor(red: 0.80, green: 0.55, blue: 1.00, alpha: 1)
            )
        case .unknown:
            return .gray
        }
    }
}

extension Color {
    static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
}
