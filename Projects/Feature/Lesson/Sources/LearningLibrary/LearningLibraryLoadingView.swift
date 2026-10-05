import SwiftUI

import DesignSystem

struct LearningLibraryLoadingView: View {
    @ScaledMetric private var captionSize: CGFloat = DesignSystemTypography.Pretendard.semiBold13_5.size

    var body: some View {
        VStack(spacing: 22) {
            HStack(spacing: 12) {
                PulseDot(delay: 0)
                PulseDot(delay: 0.18)
                PulseDot(delay: 0.36)
            }
            .frame(height: 24)
            Text("학습 라이브러리를 불러오는 중")
                .typography(DesignSystemTypography.Pretendard.semiBold13_5.scaled(to: CGFloat(captionSize)))
                .foregroundStyle(DesignSystemColor.Foreground.subtle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystemColor.Base.white)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("학습 라이브러리를 불러오는 중")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    LearningLibraryLoadingView()
}
