import SwiftUI

import DesignSystem
import DomainInterface

struct MultipleChoiceWordHeader: View {
    let word: Lesson.Word

    var body: some View {
        VStack(spacing: 10) {
            Text(word.term)
                .typography(DesignSystemTypography.Pretendard.extraBold40)
                .foregroundStyle(DesignSystemColor.Base.white)
                .multilineTextAlignment(.center)

            Text("알맞은 뜻을 고르세요")
                .typography(DesignSystemTypography.Pretendard.medium14)
                .foregroundStyle(DesignSystemColor.Base.white.opacity(0.55))
        }
        .padding(.horizontal, 28)
    }
}
