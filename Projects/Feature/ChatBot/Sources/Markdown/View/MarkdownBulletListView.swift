import SwiftUI

import DesignSystem

struct MarkdownBulletListView: View {
    let items: [MarkdownListItem]

    private static let fontSize: CGFloat = DesignSystemTypography.Pretendard.regular15.size

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(DesignSystemColor.Foreground.subtle)
                        .frame(width: 4, height: 4)
                        .padding(.top, 8)
                    Text(MarkdownInlineStyler.styled(item.text, baseSize: Self.fontSize))
                        .typography(DesignSystemTypography.Pretendard.regular15)
                        .foregroundStyle(DesignSystemColor.Foreground.default)
                }
                .padding(.leading, CGFloat(item.depth) * 16)
            }
        }
    }
}
