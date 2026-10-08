import SwiftUI

/// Colors from the Figma Foundations palette. The nested names mirror Figma's token paths.
public enum DesignSystemColor {
    /// Transparent color for layout and alpha masks; adds no palette asset.
    public static var clear: Color { Base.white.opacity(0) }

    public enum Accent {
        public static let ctaIcon = DesignSystemAsset.ctaIcon.swiftUIColor
        public static let primary = DesignSystemAsset.primary.swiftUIColor
        public static let recordDotPurple = DesignSystemAsset.recordDotPurple.swiftUIColor
        public static let selectedBlue = DesignSystemAsset.selectedBlue.swiftUIColor
        public static let selectedBlue100 = DesignSystemAsset.selectedBlue100.swiftUIColor
        /// 어두운 배경 위 텍스트·아이콘용. 채움은 `selectedBlue`를 쓴다.
        public static let selectedBlueText = DesignSystemAsset.selectedBlueText.swiftUIColor
    }

    public enum Background {
        /// 화면·카드 기본 면. 다크 모드에서 어두워진다.
        public static let base = DesignSystemAsset.bgBase.swiftUIColor
        /// 배경 위에 떠 있는 버튼 등 한 단계 밝은 면.
        public static let elevated = DesignSystemAsset.bgElevated.swiftUIColor
        public static let muted = DesignSystemAsset.bgMuted.swiftUIColor
    }

    public enum Base {
        /// 모드와 상관없이 항상 흰색. 게임 화면·컬러 버튼 위 글자용이며 화면 배경에는 `Background.base`를 쓴다.
        public static let white = DesignSystemAsset.white.swiftUIColor
    }

    public enum Border {
        public static let `default` = DesignSystemAsset.border.swiftUIColor
        public static let line = DesignSystemAsset.line.swiftUIColor
        public static let subtle = DesignSystemAsset.borderSubtle.swiftUIColor
    }

    public enum Foreground {
        public static let `default` = DesignSystemAsset.fg.swiftUIColor
        public static let muted = DesignSystemAsset.fgMuted.swiftUIColor
        public static let strong = DesignSystemAsset.fgStrong.swiftUIColor
        public static let subtle = DesignSystemAsset.fgSubtle.swiftUIColor
    }

    public enum Game {
        public static let base = DesignSystemAsset.game.swiftUIColor
        public static let dark = DesignSystemAsset.gameDark.swiftUIColor
        public static let deep = DesignSystemAsset.gameDeep.swiftUIColor
    }

    public enum Gradient {
        public static let ctaEnd = DesignSystemAsset.ctaGradientEnd.swiftUIColor
        public static let ctaMid = DesignSystemAsset.ctaGradientMid.swiftUIColor
        public static let ctaStart = DesignSystemAsset.ctaGradientStart.swiftUIColor
    }

    public enum Spectrum {
        public static let blue = DesignSystemAsset.spectrumBlue.swiftUIColor
        public static let purple = DesignSystemAsset.spectrumPurple.swiftUIColor
        public static let teal = DesignSystemAsset.spectrumTeal.swiftUIColor
    }

    public enum Stage {
        public static let basicDark = DesignSystemAsset.stageBasicDark.swiftUIColor
        public static let introLight = DesignSystemAsset.stageIntroLight.swiftUIColor
        public static let progressTrack = DesignSystemAsset.progressTrack.swiftUIColor
    }

    public enum Status {
        public static let negative = DesignSystemAsset.negative.swiftUIColor
        /// 어두운 배경 위 텍스트·아이콘용. 채움은 `negative`를 쓴다.
        public static let negativeText = DesignSystemAsset.negativeText.swiftUIColor
        public static let positive = DesignSystemAsset.positive.swiftUIColor
    }

    public enum Text {
        public static let caption = DesignSystemAsset.textCaption.swiftUIColor
        public static let secondary = DesignSystemAsset.textSecondary.swiftUIColor
    }
}
