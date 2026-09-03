import SwiftUI

import DesignSystem

/// `MarkdownInlineParser`가 만든 의미 속성(굵게/기울임/코드/하이라이트/링크)에
/// DesignSystem 폰트·색 토큰을 적용한다. 파싱(의미)과 스타일링(디자인)을 분리해
/// 파서가 DesignSystem 없이도 테스트 가능하게 한다.
enum MarkdownInlineStyler {
    static func styled(_ text: AttributedString, baseSize: CGFloat) -> AttributedString {
        var result = text
        for run in text.runs {
            let range = run.range

            var font = DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: baseSize)
            var color = DesignSystemAsset.fg.swiftUIColor

            if run.inlinePresentationIntent?.contains(.stronglyEmphasized) == true {
                font = DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: baseSize)
                color = DesignSystemAsset.fgStrong.swiftUIColor
            }
            if run.inlinePresentationIntent?.contains(.emphasized) == true {
                font = font.italic()
            }
            if run.inlinePresentationIntent?.contains(.code) == true {
                font = .system(size: baseSize, design: .monospaced)
                color = DesignSystemAsset.study300.swiftUIColor
                result[range].backgroundColor = DesignSystemAsset.study100.swiftUIColor
            }
            if run.markdownHighlight == true {
                result[range].backgroundColor = DesignSystemAsset.highlightBg.swiftUIColor
            }
            if run.link != nil {
                color = DesignSystemAsset.primary.swiftUIColor
                result[range].underlineStyle = .single
            }
            if let tailOpacity = run.markdownTailOpacity {
                color = color.opacity(tailOpacity)
                // 배경(코드/하이라이트)에도 같은 불투명도를 곱해, 페이드 구간에서 글자만 옅어지고
                // 배경만 진하게 남는 현상을 막는다.
                if let background = result[range].backgroundColor {
                    result[range].backgroundColor = background.opacity(tailOpacity)
                }
            }

            result[range].font = font
            result[range].foregroundColor = color
        }
        return result
    }
}
