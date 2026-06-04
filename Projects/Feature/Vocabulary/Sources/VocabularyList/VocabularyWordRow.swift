import DesignSystem
import SwiftUI

struct VocabularyWordRow: View {
    let word: VocabularyListPresentationModel.WordRow
    let onTapped: () -> Void

    var body: some View {
        Button(action: onTapped) {
            HStack(alignment: .center, spacing: 12) {
                WordTextStack(word: word)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
            }
            .padding(16)
            .background(DesignSystemAsset.background.swiftUIColor)
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(DesignSystemAsset.border.swiftUIColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct WordTextStack: View {
    let word: VocabularyListPresentationModel.WordRow

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(word.term)
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                    .kerning(-0.012 * 18)
                Text(word.pronunciation)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            }
            Text(word.primaryMeaning)
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                .foregroundStyle(DesignSystemAsset.fg.swiftUIColor)
        }
    }
}
