import SwiftUI

import DesignSystem

struct HomeTopBar: View {
    let onTapped: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: onTapped) {
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DesignSystemAsset.study300.swiftUIColor)
                    .frame(width: 36, height: 36)
            }
            .accessibilityLabel("학습 라이브러리")
        }
        .padding(.top, 6)
        .padding(.horizontal, 20)
    }
}
