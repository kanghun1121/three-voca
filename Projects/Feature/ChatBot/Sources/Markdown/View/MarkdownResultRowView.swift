import SwiftUI

import DesignSystem

/// 정답 ✓ / 오답 ✗ 최소 대조쌍 한 줄. 초록/빨강 전폭 칩.
struct MarkdownResultRowView: View {
    let item: MarkdownResultItem

    private static let fontSize: CGFloat = DesignSystemTypography.Pretendard.regular15.size

    var body: some View {
        HStack(spacing: 8) {
            Text(item.kind == .correct ? "✓" : "✗")
                .typography(DesignSystemTypography.Pretendard.bold15)
                .foregroundStyle(iconColor)
            Text(MarkdownInlineStyler.styled(item.text, baseSize: Self.fontSize))
                .typography(DesignSystemTypography.Pretendard.regular15)
                .foregroundStyle(DesignSystemColor.Foreground.default)
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
            ? DesignSystemColor.Status.positive
            : DesignSystemColor.Status.negativeText
    }

    private var backgroundColor: Color {
        item.kind == .correct
            ? DesignSystemColor.Status.positive.opacity(0.12)
            : DesignSystemColor.Status.negative.opacity(0.08)
    }
}
