import DesignSystem
import SwiftUI

struct VocabularyListBottomBar: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(DesignSystemAsset.background.swiftUIColor)
        .overlay(alignment: .top) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(DesignSystemAsset.borderSubtle.swiftUIColor)
        }
    }
}
