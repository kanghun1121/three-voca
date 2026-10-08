import SwiftUI

import DesignSystem

struct MarkdownTableCellView: View {
    let text: AttributedString
    let isHeader: Bool
    let horizontalPadding: CGFloat

    var body: some View {
        Text(MarkdownInlineStyler.styled(text, baseSize: fontSize))
            .typography(typography)
            .foregroundStyle(color)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 8)
    }

    private var fontSize: CGFloat { typography.size }

    private var typography: DesignSystemTypography {
        isHeader ? DesignSystemTypography.Markdown.tableHeader : DesignSystemTypography.Markdown.tableBody
    }

    private var color: Color {
        isHeader ? DesignSystemColor.Foreground.muted : DesignSystemColor.Foreground.default
    }
}
