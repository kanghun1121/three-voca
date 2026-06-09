import SwiftUI

import DesignSystem
import FeatureWordGameInterface

struct PronunciationView: View {
    let word: GameWord
    let isListening: Bool
    let onMicTap: () -> Void

    private var syllables: [String] {
        // 음절은 pronunciation에서 파싱하거나, term에서 단순 분리
        // 실제 syllable 분리는 AudioClient 데이터를 활용할 수 있으나
        // 여기서는 term을 4자 단위로 단순 분리
        let term = word.term
        var result: [String] = []
        var start = term.startIndex
        let step = max(2, term.count / 3)
        while start < term.endIndex {
            let end = term.index(start, offsetBy: step, limitedBy: term.endIndex) ?? term.endIndex
            result.append(String(term[start..<end]))
            start = end
        }
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(word.term)
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 52))
                .tracking(-0.03 * 52)
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                .padding(.bottom, 20)

            syllableRow

            Spacer().frame(height: 40)

            AudioWaveformView(isAnimating: isListening)
                .padding(.horizontal, 22)

            Spacer()

            footer
        }
    }

    private var syllableRow: some View {
        HStack(spacing: 8) {
            ForEach(syllables, id: \.self) { syllable in
                Text(syllable)
                    .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.80))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(DesignSystemAsset.white.swiftUIColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 16) {
            Text(isListening ? "듣고 있어요..." : "마이크를 탭해 발음하세요")
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.70))
                .animation(.default, value: isListening)

            Button(action: onMicTap) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        isListening
                        ? DesignSystemAsset.white.swiftUIColor
                        : DesignSystemAsset.game.swiftUIColor
                    )
                    .frame(width: 72, height: 72)
                    .background(
                        isListening
                        ? DesignSystemAsset.game.swiftUIColor
                        : DesignSystemAsset.white.swiftUIColor
                    )
                    .clipShape(Circle())
            }
            .animation(.easeInOut(duration: 0.2), value: isListening)
        }
        .padding(.bottom, 52)
    }
}
