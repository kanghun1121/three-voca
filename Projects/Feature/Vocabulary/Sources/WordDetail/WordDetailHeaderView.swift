import DesignSystem
import SwiftUI

struct WordDetailHeaderView: View {
    let term: String
    let pronunciation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WordModeBadge()
                .padding(.bottom, 14)
            Text(term)
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 40))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .kerning(-0.025 * 40)
            PronunciationRow(pronunciation: pronunciation)
                .padding(.top, 8)
        }
    }
}

private struct PronunciationRow: View {
    let pronunciation: String

    var body: some View {
        HStack(spacing: 10) {
            Text(pronunciation)
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            AudioButton()
        }
    }
}

private struct AudioButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "speaker.wave.2")
                .font(.system(size: 14))
                .foregroundStyle(DesignSystemAsset.study300.swiftUIColor)
        }
        .accessibilityLabel("발음 듣기")
        .frame(width: 32, height: 32)
        .background(DesignSystemAsset.background.swiftUIColor)
        .clipShape(Circle())
        .overlay { Circle().stroke(DesignSystemAsset.border.swiftUIColor, lineWidth: 1) }
        .buttonStyle(.plain)
    }
}

private struct WordModeBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "book")
                .font(.system(size: 11))
            Text("단어 보기")
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 11))
        }
        .foregroundStyle(DesignSystemAsset.study300.swiftUIColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(DesignSystemAsset.study100.swiftUIColor)
        .clipShape(Capsule())
    }
}
