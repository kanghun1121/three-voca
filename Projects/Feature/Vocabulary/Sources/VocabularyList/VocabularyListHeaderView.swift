import DesignSystem
import SwiftUI

struct VocabularyListHeaderView: View {
    let modeLabel: String
    let wordCountText: String
    let sessionInfoText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ModeLabelBadge(text: modeLabel)
            Text(wordCountText)
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 33))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            Text(sessionInfoText)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
        }
    }
}

private struct ModeLabelBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
            .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(DesignSystemAsset.study100.swiftUIColor)
            .clipShape(.capsule)
    }
}
