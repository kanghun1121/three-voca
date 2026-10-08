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

            var typography = DesignSystemTypography.Pretendard.regular15.scaled(to: baseSize)
            var color = DesignSystemColor.Foreground.default

            if run.inlinePresentationIntent?.contains(.stronglyEmphasized) == true {
                typography = DesignSystemTypography.Pretendard.bold15.scaled(to: baseSize)
                color = DesignSystemColor.Foreground.strong
            }
            if run.inlinePresentationIntent?.contains(.code) == true {
                typography = DesignSystemTypography.Markdown.code.scaled(to: baseSize)
                color = DesignSystemColor.Accent.selectedBlueText
                result[range].backgroundColor = DesignSystemColor.Accent.selectedBlue100
            }
            if run.markdownHighlight == true {
                result[range].backgroundColor = DesignSystemColor.Accent.selectedBlue100
            }
            if run.link != nil {
                color = DesignSystemColor.Accent.primary
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

            let isItalic = run.inlinePresentationIntent?.contains(.emphasized) == true
                && run.inlinePresentationIntent?.contains(.code) != true
            result[range].font = isItalic ? typography.italicFont : typography.font
            result[range].foregroundColor = color
        }
        return result
    }
}
