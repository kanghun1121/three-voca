import SwiftUI

import DesignSystem
import DomainInterface

struct SessionRow: View {
    let lesson: LessonProgress
    let level: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                SessionIndexBadge(sessionNumber: lesson.lessonNumber, isCompleted: lesson.status == .completed, level: level)
                SessionTitleLabel(lesson: lesson)
                Spacer()
                Image(systemName: "chevron.right")
                    .typography(DesignSystemTypography.Pretendard.semiBold13)
                    .foregroundStyle(DesignSystemColor.Text.caption)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(lesson.lessonNumber)번째 세션, 단어 \(lesson.totalWords)개, \(statusAccessibilityLabel)")
    }

    private var statusAccessibilityLabel: String {
        lesson.status == .completed ? "완료" : "학습 전"
    }
}
