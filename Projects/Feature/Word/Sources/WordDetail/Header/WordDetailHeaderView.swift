import SwiftUI

import DesignSystem

struct WordDetailHeaderView: View {
    let term: String
    let pronunciation: String
    let onPronunciationTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(term)
                .typography(DesignSystemTypography.Pretendard.extraBold40)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
            PronunciationRow(pronunciation: pronunciation, onPronunciationTapped: onPronunciationTapped)
                .padding(.top, 8)
        }
    }
}

private struct PronunciationRow: View {
    let pronunciation: String
    let onPronunciationTapped: () -> Void

    @ScaledMetric private var fontSize: Double = Double(DesignSystemTypography.Mono.regular14.size)

    var body: some View {
        HStack(spacing: 10) {
            Text(pronunciation)
                .typography(DesignSystemTypography.Mono.regular14.scaled(to: CGFloat(fontSize)))
                .foregroundStyle(DesignSystemColor.Foreground.muted)
            AudioButton(action: onPronunciationTapped)
        }
    }
}

private struct AudioButton: View {
    let action: () -> Void

    @ScaledMetric private var iconSize: Double = Double(DesignSystemTypography.Pretendard.regular16.size)

    var body: some View {
        Button(action: action) {
            Image(systemName: "speaker.wave.2")
                .typography(DesignSystemTypography.Pretendard.regular16.scaled(to: CGFloat(iconSize)))
                .foregroundStyle(DesignSystemColor.Accent.selectedBlueText)
                .frame(width: 34, height: 34)
                .background(DesignSystemColor.Background.elevated)
                .clipShape(Circle())
                .overlay { Circle().stroke(DesignSystemColor.Border.default, lineWidth: 1) }
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("발음 듣기")
    }
}
