import SwiftUI

import DesignSystem

/// 콜아웃 3종(핵심/주의/팁). 좌측 바 + 배경, 종류별 색은 `MarkdownCalloutKind` 매핑을 따른다.
struct MarkdownCalloutView: View {
    let kind: MarkdownCalloutKind
    let title: AttributedString
    let bodyLines: [AttributedString]

    init(kind: MarkdownCalloutKind, title: AttributedString, body: [AttributedString]) {
        self.kind = kind
        self.title = title
        self.bodyLines = body
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Rectangle()
                .fill(accentColor)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 4) {
                Text(MarkdownInlineStyler.styled(title, baseSize: 12.5))
                    .typography(DesignSystemTypography.Pretendard.bold12_5)
                    .foregroundStyle(accentColor)
                ForEach(Array(bodyLines.enumerated()), id: \.offset) { _, line in
                    Text(MarkdownInlineStyler.styled(line, baseSize: 13.5))
                        .typography(DesignSystemTypography.Pretendard.regular13_5)
                        .foregroundStyle(DesignSystemColor.Foreground.default)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var accentColor: Color {
        switch kind {
        case .key: DesignSystemColor.Accent.selectedBlue
        case .caution: DesignSystemColor.Status.negative
        case .tip: DesignSystemColor.Foreground.subtle
        }
    }

    private var backgroundColor: Color {
        switch kind {
        case .key: DesignSystemColor.Accent.selectedBlue100
        case .caution: DesignSystemColor.Status.negative.opacity(0.12)
        case .tip: DesignSystemColor.Background.muted
        }
    }
}
