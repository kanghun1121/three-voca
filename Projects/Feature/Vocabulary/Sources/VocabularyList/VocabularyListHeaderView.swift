import DesignSystem
import SwiftUI

struct VocabularyListHeaderView: View {
    let level: Int
    let sessionNumber: Int
    let wordCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ModeLabelBadge()
            Text("\(wordCount)개 단어")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 33))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            Text("Level \(level) · Session \(sessionNumber)")
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
        }
    }
}

private struct ModeLabelBadge: View {
    var body: some View {
        Text("단어 보기 모드")
            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
            .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(DesignSystemAsset.study100.swiftUIColor)
            .clipShape(.capsule)
    }
}
