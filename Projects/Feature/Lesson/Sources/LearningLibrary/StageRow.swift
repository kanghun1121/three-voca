import SwiftUI

import DesignSystem
import DomainInterface

/// 헤어라인 목록의 단계 행. 카드/보더 없이 3px 키라인 + 단계명/설명 + 우측 진도수치 + 하단 2px 트랙으로만 구성한다.
struct StageRow: View {
    let level: LevelSummary
    let onTap: () -> Void

    private var isLocked: Bool { level.isLocked }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
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
                        .stageTypography(.progressFigure)
                        .foregroundStyle(textColor)
                }
                StageProgressTrack(ratio: isLocked ? 0 : level.progressRatio, fillColor: keylineColor, height: 3)
            }
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }

    private var keylineColor: Color {
        isLocked ? DesignSystemAsset.stageLockedKeyline.swiftUIColor : StageColor.resolveLight(forLevel: level.level)
    }

    private var textColor: Color {
        isLocked ? DesignSystemAsset.textCaption.swiftUIColor : DesignSystemAsset.fgStrong.swiftUIColor
    }

    private var secondaryTextColor: Color {
        isLocked ? DesignSystemAsset.textCaption.swiftUIColor : DesignSystemAsset.textSecondary.swiftUIColor
    }

    private var progressText: String {
        isLocked ? "—" : "\(level.completedLessons)/\(level.totalLessons)"
    }

    private var descriptionText: String {
        StageDescription.resolveText(forLevel: level.level) ?? "준비 중"
    }
}
