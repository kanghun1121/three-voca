import SwiftUI

import DesignSystem

struct WordDetailHeaderView: View {
    let term: String
    let pronunciation: String
    let onPronunciationTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(term)
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 40))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .kerning(-0.025 * 40)
            PronunciationRow(pronunciation: pronunciation, onPronunciationTapped: onPronunciationTapped)
                .padding(.top, 8)
        }
    }
}

private struct PronunciationRow: View {
    let pronunciation: String
    let onPronunciationTapped: () -> Void

    @ScaledMetric private var fontSize: CGFloat = 14

    var body: some View {
        HStack(spacing: 10) {
            Text(pronunciation)
                .font(.system(size: fontSize, design: .monospaced))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            AudioButton(action: onPronunciationTapped)
        }
    }
}

private struct AudioButton: View {
    let action: () -> Void

    @ScaledMetric private var iconSize: CGFloat = 14

    var body: some View {
        Button(action: action) {
            Image(systemName: "speaker.wave.2")
                .font(.system(size: iconSize))
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


