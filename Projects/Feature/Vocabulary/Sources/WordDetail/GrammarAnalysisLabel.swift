import SwiftUI

import DesignSystem

struct GrammarAnalysisLabel: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "rectangle.grid.2x2")
                .font(.system(size: 11))
            Text("문법 분석")
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
        }
        .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
    }
}
