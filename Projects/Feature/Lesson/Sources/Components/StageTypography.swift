import SwiftUI

import DesignSystem

/// 핸드오프 #123 시안 A 타이포그래피 토큰. LearningLibrary·StageDetail 두 화면이 공유한다.
/// tracking은 핸드오프의 em 단위 letter-spacing을 각 폰트 크기 기준 pt로 환산한 값이다.
enum StageTypography {
    struct Style {
        let font: Font
        let tracking: CGFloat
    }
}

extension StageTypography.Style {
    static let listTitle = Self(font: DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 29), tracking: -1.0)
    static let listSubtitle = Self(font: DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12), tracking: 0)
    static let stageName = Self(font: DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 17.5), tracking: -0.3875)
    static let stageDescription = Self(font: DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12.5), tracking: -0.115)
    static let progressFigure = Self(font: DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 13), tracking: 0)
    static let stepLabel = Self(font: DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 11), tracking: 0.88)
    static let detailStageName = Self(font: DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 26), tracking: -1.04)
    static let sessionName = Self(font: DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 14), tracking: -0.28)
}

extension View {
    func stageTypography(_ style: StageTypography.Style) -> some View {
        font(style.font).tracking(style.tracking)
    }
}
