import SwiftUI

import DesignSystem

/// 단계(1~6) 인덱스 → 컬러 매핑 (핸드오프 #123 시안 A). `light`는 키라인·트랙처럼 텍스트가
/// 없는 면에, `dark`는 흰 텍스트/체크가 올라가는 면에 쓴다. 심화·완성은 시안에 dark 톤이
/// 없어 `light`와 같은 값을 반환하므로, 이 두 단계에서는 흰 텍스트/체크를 올리는 용도로
/// 쓰지 않는다(LearningLibrary·StageDetail 두 화면이 공유한다).
enum StageColor {
    static func resolveLight(forLevel level: Int) -> Color {
        resolveTone(forLevel: level).light
    }

    static func resolveDark(forLevel level: Int) -> Color {
        resolveTone(forLevel: level).dark
    }

    private static func resolveTone(forLevel level: Int) -> (light: Color, dark: Color) {
        switch level {
        case 1: (DesignSystemColor.Stage.introLight, DesignSystemColor.Accent.selectedBlue)
        case 2: (DesignSystemColor.Spectrum.blue, DesignSystemColor.Stage.basicDark)
        case 3: (DesignSystemColor.Spectrum.purple, DesignSystemColor.Accent.recordDotPurple)
        case 4: (DesignSystemColor.Spectrum.purple, DesignSystemColor.Accent.recordDotPurple)
        case 5: (DesignSystemColor.Spectrum.teal.opacity(0.65), DesignSystemColor.Spectrum.teal.opacity(0.65))
        default: (DesignSystemColor.Spectrum.teal, DesignSystemColor.Spectrum.teal)
        }
    }
}
