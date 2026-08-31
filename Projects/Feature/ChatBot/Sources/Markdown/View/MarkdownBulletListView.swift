import SwiftUI

import DesignSystem

struct MarkdownBulletListView: View {
    let items: [MarkdownListItem]

    private static let fontSize: CGFloat = 15

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(DesignSystemAsset.fgSubtle.swiftUIColor)
                        .frame(width: 4, height: 4)
                        .padding(.top, 8)
                    Text(MarkdownInlineStyler.styled(item.text, baseSize: Self.fontSize))
                        .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: Self.fontSize))
                        .foregroundStyle(DesignSystemAsset.fg.swiftUIColor)
                }
                .padding(.leading, CGFloat(item.depth) * 16)
            }
        }
    }
}
