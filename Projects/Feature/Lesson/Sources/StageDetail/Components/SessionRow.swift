import SwiftUI

import DesignSystem
import DomainInterface

struct SessionRow: View {
    let lesson: LessonProgress
    let status: SessionStatus
    let level: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                SessionIndexBadge(sessionNumber: lesson.lessonNumber, status: status, level: level)
                SessionTitleLabel(lesson: lesson)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DesignSystemAsset.textCaption.swiftUIColor)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(lesson.lessonNumber)번째 세션, 단어 \(lesson.totalWords)개, \(statusAccessibilityLabel)")
    }

    private var statusAccessibilityLabel: String {
        switch status {
        case .completed: "완료"
        case .active: "진행 중"
        case .upcoming: "학습 전"
        }
    }
}
