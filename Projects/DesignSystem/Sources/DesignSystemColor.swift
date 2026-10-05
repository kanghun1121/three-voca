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
    }

    public enum Background {
        public static let muted = DesignSystemAsset.bgMuted.swiftUIColor
    }

    public enum Base {
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
        public static let positive = DesignSystemAsset.positive.swiftUIColor
    }

    public enum Text {
        public static let caption = DesignSystemAsset.textCaption.swiftUIColor
        public static let secondary = DesignSystemAsset.textSecondary.swiftUIColor
    }
}
