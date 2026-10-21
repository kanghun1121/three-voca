import SwiftUI

import DesignSystem

struct WordmarkView: View {
    var body: some View {
        VStack(spacing: 22) {
            Text("DAILY VOCABULARY")
                .typography(DesignSystemTypography.Pretendard.bold12)
                .foregroundStyle(DesignSystemColor.Accent.primary.opacity(0.55))

            WordmarkTitleView()
        }
        .multilineTextAlignment(.center)
    }
}
