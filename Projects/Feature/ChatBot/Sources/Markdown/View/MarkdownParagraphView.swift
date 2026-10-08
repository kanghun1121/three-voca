import SwiftUI

import DesignSystem

struct MarkdownParagraphView: View {
    let text: AttributedString

    private static let fontSize: CGFloat = DesignSystemTypography.Pretendard.regular15.size

    var body: some View {
        Text(MarkdownInlineStyler.styled(text, baseSize: Self.fontSize))
            .typography(DesignSystemTypography.Markdown.paragraph)
            .foregroundStyle(DesignSystemColor.Foreground.default)
    }
}
