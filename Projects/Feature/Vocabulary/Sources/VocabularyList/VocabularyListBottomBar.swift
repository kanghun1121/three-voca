import DesignSystem
import SwiftUI

struct VocabularyListBottomBar: View {
    let hasRecord: Bool

    var body: some View {
        HStack {
            Text("청록 톤 — \(hasRecord ? "점수 측정 있음" : "점수 측정 없음")")
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
