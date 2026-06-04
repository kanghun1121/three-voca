import DesignSystem
import SwiftUI

struct GrammarAnalysisLabel: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "rectangle.grid.2x2")
                .font(.system(size: 13))
            Text("문법 분석")
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 12))
        }
        .foregroundStyle(DesignSystemAsset.study300.swiftUIColor)
    }
}
