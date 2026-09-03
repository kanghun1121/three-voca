import SwiftUI

import DesignSystem

struct MarkdownTableCellView: View {
    let text: AttributedString
    let isHeader: Bool
    let horizontalPadding: CGFloat

    private static let headerFontSize: CGFloat = 12.5
    private static let bodyFontSize: CGFloat = 13

    var body: some View {
        Text(MarkdownInlineStyler.styled(text, baseSize: fontSize))
            .font(font)
            .foregroundStyle(color)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 8)
    }

    private var fontSize: CGFloat { isHeader ? Self.headerFontSize : Self.bodyFontSize }

    private var font: Font {
        isHeader
            ? DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: fontSize)
            : DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: fontSize)
    }

    private var color: Color {
        isHeader ? DesignSystemAsset.fgMuted.swiftUIColor : DesignSystemAsset.fg.swiftUIColor
    }
}
