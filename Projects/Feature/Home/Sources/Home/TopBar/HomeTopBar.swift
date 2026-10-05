import SwiftUI

import DesignSystem

struct HomeTopBar: View {
    let onTapped: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button("학습 라이브러리", systemImage: "list.bullet", action: onTapped)
                .labelStyle(.iconOnly)
                .typography(DesignSystemTypography.Pretendard.semiBold18)
                .foregroundStyle(DesignSystemColor.Foreground.muted)
                .frame(minWidth: 44, minHeight: 44)
        }
        .padding(.top, 6)
        .padding(.horizontal, 20)
    }
}
