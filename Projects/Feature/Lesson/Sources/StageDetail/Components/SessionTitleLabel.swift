import SwiftUI

import DesignSystem
import DomainInterface

/// 세션명 + 단어 수 2줄 라벨. `SessionRow`에서만 쓰는 화면 전용 서브뷰.
struct SessionTitleLabel: View {
    let lesson: LessonProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(lesson.lessonNumber)번째 세션")
                .stageTypography(.sessionName)
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            Text("단어 \(lesson.totalWords)개")
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
        }
    }
}
