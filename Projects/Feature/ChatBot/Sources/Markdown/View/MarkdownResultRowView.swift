import SwiftUI

import DesignSystem

/// 정답 ✓ / 오답 ✗ 최소 대조쌍 한 줄. 초록/빨강 전폭 칩.
struct MarkdownResultRowView: View {
    let item: MarkdownResultItem

    private static let fontSize: CGFloat = 15

    var body: some View {
        HStack(spacing: 8) {
            Text(item.kind == .correct ? "✓" : "✗")
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: Self.fontSize))
                .foregroundStyle(iconColor)
            Text(MarkdownInlineStyler.styled(item.text, baseSize: Self.fontSize))
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: Self.fontSize))
                .foregroundStyle(DesignSystemAsset.fg.swiftUIColor)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var iconColor: Color {
        item.kind == .correct
            ? DesignSystemAsset.positive.swiftUIColor
            : DesignSystemAsset.negative.swiftUIColor
    }

    private var backgroundColor: Color {
        item.kind == .correct
            ? DesignSystemAsset.positive100.swiftUIColor
            : DesignSystemAsset.negative.swiftUIColor.opacity(0.08)
    }
}
