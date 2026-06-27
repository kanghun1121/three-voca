import SwiftUI

import DesignSystem

struct WordmarkView: View {
    var body: some View {
        VStack(spacing: 22) {
            Text("DAILY VOCABULARY")
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                .tracking(3.6)
                .foregroundStyle(DesignSystemAsset.primary.swiftUIColor.opacity(0.55))

            WordmarkTitleView()
        }
        .multilineTextAlignment(.center)
    }
}
