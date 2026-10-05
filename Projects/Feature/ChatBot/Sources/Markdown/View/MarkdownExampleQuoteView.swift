import SwiftUI

import DesignSystem

/// 예문 인용(`> **영문**` + `> 한국어`). 좌측 틸 바만, 배경 없음.
struct MarkdownExampleQuoteView: View {
    let english: AttributedString
    let korean: AttributedString?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Rectangle()
                .fill(DesignSystemColor.Accent.selectedBlue)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 4) {
                Text(MarkdownInlineStyler.styled(english, baseSize: 15))
                    .typography(DesignSystemTypography.Pretendard.bold15)
                    .foregroundStyle(DesignSystemColor.Foreground.strong)
                if let korean {
                    Text(MarkdownInlineStyler.styled(korean, baseSize: 13.5))
                        .typography(DesignSystemTypography.Pretendard.regular13_5)
                        .foregroundStyle(DesignSystemColor.Foreground.muted)
                }
            }
        }
    }
}
