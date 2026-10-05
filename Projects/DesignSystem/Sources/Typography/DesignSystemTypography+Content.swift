import SwiftUI

public extension DesignSystemTypography {
    enum Content {
        public static let bodyMedium = DesignSystemTypography(family: .pretendard(.medium), size: 17, scalesWithBody: true)
        public static let bodySemiBold = DesignSystemTypography(family: .pretendard(.semiBold), size: 17, scalesWithBody: true)
        public static let loginSubhead = DesignSystemTypography(family: .pretendard(.regular), size: 14)
        public static let wordDefinition = DesignSystemTypography(family: .pretendard(.semiBold), size: 17)
        public static let gameCompletionSubtitle = DesignSystemTypography(family: .pretendard(.medium), size: 16)
    }

    enum Markdown {
        public static let paragraph = DesignSystemTypography(family: .pretendard(.regular), size: 15)
        public static let heading1 = DesignSystemTypography(family: .pretendard(.bold), size: 19)
        public static let heading2 = DesignSystemTypography(family: .pretendard(.bold), size: 17)
        public static let heading3 = DesignSystemTypography(family: .pretendard(.bold), size: 15.5)
        public static let heading4 = DesignSystemTypography(family: .pretendard(.medium), size: 12)
        public static let tableHeader = DesignSystemTypography(family: .pretendard(.semiBold), size: 12.5)
        public static let tableBody = DesignSystemTypography(family: .pretendard(.regular), size: 13)
        public static let code = DesignSystemTypography(family: .mono(.regular), size: 15)
    }
}
