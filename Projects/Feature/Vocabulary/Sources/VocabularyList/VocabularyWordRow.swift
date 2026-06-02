import DesignSystem
import SwiftUI

struct VocabularyWordRow: View {
    let word: VocabularyListPresentationModel.WordRow
    let onTapped: () -> Void

    var body: some View {
        Button(action: onTapped) {
            HStack(alignment: .center) {
                WordTextStack(word: word)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(DesignSystemAsset.white.swiftUIColor)
            .clipShape(.rect(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

private struct WordTextStack: View {
    let word: VocabularyListPresentationModel.WordRow

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(word.term)
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                Text(word.pronunciation)
                    .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            }
            Text(word.primaryMeaning)
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
        }
    }
}
