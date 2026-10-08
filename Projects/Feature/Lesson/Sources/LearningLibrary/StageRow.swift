import SwiftUI

import DesignSystem
import DomainInterface

/// 헤어라인 목록의 단계 행. 카드/보더 없이 3px 키라인 + 단계명/설명 + 우측 진도수치로만 구성한다.
struct StageRow: View {
    let level: LevelSummary
    let onTap: () -> Void

    private var isLocked: Bool { level.isLocked }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 16) {
                StageKeylineBar(color: keylineColor, width: 3, height: 32)
                StageNameLabel(
                    name: level.name,
                    description: descriptionText,
                    textColor: textColor,
                    secondaryColor: secondaryTextColor
                )
                Spacer()
                Text(progressText)
                    .typography(DesignSystemTypography.Stage.progressFigure)
                    .foregroundStyle(textColor)
            }
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }

    private var keylineColor: Color {
        isLocked ? DesignSystemColor.Border.line : StageColor.resolveLight(forLevel: level.level)
    }

    private var textColor: Color {
        isLocked ? DesignSystemColor.Text.caption : DesignSystemColor.Foreground.strong
    }

    private var secondaryTextColor: Color {
        isLocked ? DesignSystemColor.Text.caption : DesignSystemColor.Text.secondary
    }

    private var progressText: String {
        isLocked ? "—" : "\(level.completedLessons)/\(level.totalLessons)"
    }

    private var descriptionText: String {
        StageDescription.resolveText(forLevel: level.level) ?? "준비 중"
    }
}
