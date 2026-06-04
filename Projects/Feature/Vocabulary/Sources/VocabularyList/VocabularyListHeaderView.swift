import DesignSystem
import SwiftUI

struct VocabularyListHeaderView: View {
    let level: Int
    let sessionNumber: Int
    let wordCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ModeLabelBadge()
                .padding(.bottom, 10)
            Text("\(wordCount)개 단어")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 28))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .kerning(-0.025 * 28)
            Text("Level \(level) · Session \(sessionNumber)")
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
                .padding(.top, 4)
        }
    }
}

private struct ModeLabelBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "book")
                .font(.system(size: 12))
            Text("단어 보기 모드")
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 12))
        }
        .foregroundStyle(DesignSystemAsset.study300.swiftUIColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(DesignSystemAsset.study100.swiftUIColor)
        .clipShape(Capsule())
    }
}
