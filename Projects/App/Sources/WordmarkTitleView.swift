import SwiftUI

import DesignSystem

struct WordmarkTitleView: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("쓰리")
                .foregroundStyle(DesignSystemColor.Foreground.strong)
            Text("보카")
                .foregroundStyle(DesignSystemColor.Accent.primary)
        }
        .typography(DesignSystemTypography.Pretendard.extraBold60)
    }
}
