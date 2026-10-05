import SwiftUI

import DesignSystem

struct MarkdownOrderedListView: View {
    let items: [MarkdownListItem]

    private static let fontSize: CGFloat = DesignSystemTypography.Pretendard.regular15.size

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .typography(DesignSystemTypography.Pretendard.semiBold15)
                        .foregroundStyle(DesignSystemColor.Accent.selectedBlueText)
                    Text(MarkdownInlineStyler.styled(item.text, baseSize: Self.fontSize))
                        .typography(DesignSystemTypography.Pretendard.regular15)
                        .foregroundStyle(DesignSystemColor.Foreground.default)
                }
            }
        }
    }
}
