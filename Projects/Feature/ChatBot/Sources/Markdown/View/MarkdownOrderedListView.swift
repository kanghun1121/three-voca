import SwiftUI

import DesignSystem

struct MarkdownOrderedListView: View {
    let items: [MarkdownListItem]

    private static let fontSize: CGFloat = 15

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: Self.fontSize))
                        .foregroundStyle(DesignSystemAsset.study300.swiftUIColor)
                    Text(MarkdownInlineStyler.styled(item.text, baseSize: Self.fontSize))
                        .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: Self.fontSize))
                        .foregroundStyle(DesignSystemAsset.fg.swiftUIColor)
                }
            }
        }
    }
}
