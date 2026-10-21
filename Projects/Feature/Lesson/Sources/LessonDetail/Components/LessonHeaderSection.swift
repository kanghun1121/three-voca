import SwiftUI

import DesignSystem

struct LessonHeaderSection: View {
    let level: Int
    let lessonNumber: Int
    let wordCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("LEVEL \(level) · LESSON \(lessonNumber)")
                .typography(DesignSystemTypography.Pretendard.bold14)
                .foregroundStyle(DesignSystemColor.Accent.primary)
            Text("\(wordCount)개 단어")
                .typography(DesignSystemTypography.Pretendard.extraBold33)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
        }
    }
}
