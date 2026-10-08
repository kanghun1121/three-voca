import SwiftUI

public extension DesignSystemTypography {
    enum Mono {
        public static let body = DesignSystemTypography(family: .mono(.regular), size: 17, scalesWithBody: true)
        public static let bold22 = DesignSystemTypography(family: .mono(.bold), size: 22)
        public static let regular12 = DesignSystemTypography(family: .mono(.regular), size: 12)
        public static let regular12_5 = DesignSystemTypography(family: .mono(.regular), size: 12.5)
        public static let regular14 = DesignSystemTypography(family: .mono(.regular), size: 14)
        public static let regular17 = DesignSystemTypography(family: .mono(.regular), size: 17)
    }
}
