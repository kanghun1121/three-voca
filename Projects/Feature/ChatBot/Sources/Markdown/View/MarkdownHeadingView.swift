import SwiftUI

import DesignSystem

/// `#`(굵게)/`##`(단계 구분, 틸 도트 + 굵게)/`###`(하위 제목, 굵게)/`####`(맨 끝 라벨) 헤딩 렌더.
struct MarkdownHeadingView: View {
    let level: Int
    let text: AttributedString

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            if level == 2 {
                Circle()
                    .fill(DesignSystemColor.Spectrum.blue)
                    .frame(width: 6, height: 6)
                    .offset(y: -2)
            }
            Text(MarkdownInlineStyler.styled(text, baseSize: fontSize))
                .typography(typography)
                .foregroundStyle(color)
        }
    }

    private var fontSize: CGFloat { typography.size }

    private var typography: DesignSystemTypography {
        switch level {
        case 1: DesignSystemTypography.Markdown.heading1
        case 2: DesignSystemTypography.Markdown.heading2
        case 3: DesignSystemTypography.Markdown.heading3
        default: DesignSystemTypography.Markdown.heading4
        }
    }

    private var color: Color {
        switch level {
        case 1, 2, 3: DesignSystemColor.Foreground.strong
        default: DesignSystemColor.Foreground.muted
        }
    }
}
