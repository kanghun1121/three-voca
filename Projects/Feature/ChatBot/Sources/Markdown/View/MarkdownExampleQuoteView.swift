import SwiftUI

import DesignSystem

/// 예문 인용(`> **영문**` + `> 한국어`). 좌측 틸 바만, 배경 없음.
struct MarkdownExampleQuoteView: View {
    let english: AttributedString
    let korean: AttributedString?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Rectangle()
                .fill(DesignSystemAsset.study300.swiftUIColor)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 4) {
                Text(MarkdownInlineStyler.styled(english, baseSize: 15))
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 15))
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                if let korean {
                    Text(MarkdownInlineStyler.styled(korean, baseSize: 13.5))
                        .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 13.5))
                        .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
                }
            }
        }
    }
}
