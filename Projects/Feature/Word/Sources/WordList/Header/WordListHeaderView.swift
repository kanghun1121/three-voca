import SwiftUI

import DesignSystem
import DomainInterface

struct WordListHeaderView: View {
    let level: Int
    let lessonNumber: Int
    let wordCount: Int
    let learningHistory: LearningHistory?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(wordCount)개 단어")
                .typography(DesignSystemTypography.Pretendard.extraBold28)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
            Text("Level \(level) · Lesson \(lessonNumber)")
                .typography(DesignSystemTypography.Pretendard.regular14)
                .foregroundStyle(DesignSystemColor.Foreground.muted)
                .padding(.top, 4)
            if let learningHistory {
                Text("\(learningHistory.studyCount)회 학습")
                    .typography(DesignSystemTypography.Pretendard.medium13)
                    .foregroundStyle(DesignSystemColor.Foreground.muted)
                    .padding(.top, 8)
            }
        }
    }
}

