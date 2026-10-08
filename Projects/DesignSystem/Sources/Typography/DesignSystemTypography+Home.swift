import SwiftUI

public extension DesignSystemTypography {
    enum Home {
        public static let monthHeader = DesignSystemTypography.Pretendard.bold26
        public static let weekdayHeader = DesignSystemTypography.Pretendard.semiBold11
        public static let dateNumber = DesignSystemTypography.Pretendard.medium15.monospacedDigits()
        public static let dateNumberEmphasis = DesignSystemTypography.Pretendard.bold15.monospacedDigits()
        public static let selectedDateContext = DesignSystemTypography.Pretendard.bold15
        public static let lessonCountCaption = DesignSystemTypography.Pretendard.medium12_5
        public static let ctaTitle = DesignSystemTypography.Pretendard.bold18
        public static let recordRowTitle = DesignSystemTypography.Pretendard.semiBold15
        public static let recordRowMeta = DesignSystemTypography.Pretendard.medium12_5
        public static let recordTime = DesignSystemTypography.Pretendard.medium12_5.monospacedDigits()
        public static let emptyDayTitle = DesignSystemTypography.Pretendard.semiBold14_5
        public static let emptyDaySubtext = DesignSystemTypography.Pretendard.medium12_5
    }
}
