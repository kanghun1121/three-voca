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
                    .fill(DesignSystemAsset.study300.swiftUIColor)
                    .frame(width: 6, height: 6)
                    .offset(y: -2)
            }
            Text(MarkdownInlineStyler.styled(text, baseSize: fontSize))
                .font(font)
                .foregroundStyle(color)
        }
    }

    private var fontSize: CGFloat {
        switch level {
        case 1: 19
        case 2: 17
        case 3: 15.5
        default: 12
        }
    }

    private var font: Font {
        switch level {
        case 1, 2, 3: DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: fontSize)
        default: DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: fontSize)
        }
    }

    private var color: Color {
        switch level {
        case 1, 2, 3: DesignSystemAsset.fgStrong.swiftUIColor
        default: DesignSystemAsset.fgMuted.swiftUIColor
        }
    }
}
