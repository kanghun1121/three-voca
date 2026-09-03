import SwiftUI

import DesignSystem

struct MarkdownParagraphView: View {
    let text: AttributedString

    private static let fontSize: CGFloat = 15

    var body: some View {
        Text(MarkdownInlineStyler.styled(text, baseSize: Self.fontSize))
            .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: Self.fontSize))
            .foregroundStyle(DesignSystemAsset.fg.swiftUIColor)
            .lineSpacing(6)
    }
}
