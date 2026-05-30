import DesignSystem
import SwiftUI

struct WordDetailHeaderView: View {
    let term: String
    let pronunciation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            WordModeBadge()

            Text(term)
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 32))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)

            HStack(spacing: 8) {
                Text(pronunciation)
                    .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)

                Button(action: {}) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct WordModeBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "rectangle.grid.1x2")
                .font(.system(size: 11))
            Text("단어 보기")
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
        }
        .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(DesignSystemAsset.study100.swiftUIColor)
        .clipShape(.capsule)
    }
}
