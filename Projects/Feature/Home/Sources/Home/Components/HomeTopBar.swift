import SwiftUI

import DesignSystem

struct HomeTopBar: View {
    let onTapped: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: onTapped) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
                    .frame(width: 36, height: 36)
            }
            .accessibilityLabel("학습 라이브러리")
        }
        .padding(.top, 6)
        .padding(.horizontal, 20)
    }
}
