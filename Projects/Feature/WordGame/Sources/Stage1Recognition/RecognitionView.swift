import SwiftUI

import DesignSystem
import FeatureWordGameInterface

struct RecognitionView: View {
    let word: GameWord
    let countdown: Int
    let onRemembered: () -> Void
    let onForgot: () -> Void
    let onAudio: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            CountdownRingView(value: countdown, total: 5)
                .padding(.bottom, 40)

            Text(word.term)
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 52))
                .tracking(-0.03 * 52)
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)

            Text(word.pronunciation)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.65))
                .padding(.top, 12)

            audioButton
                .padding(.top, 22)

            Spacer()

            footer
        }
    }

    private var audioButton: some View {
        Button(action: onAudio) {
            Image(systemName: "speaker.wave.2")
                .font(.system(size: 18))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                .frame(width: 44, height: 44)
                .background(DesignSystemAsset.white.swiftUIColor.opacity(0.12))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(DesignSystemAsset.white.swiftUIColor.opacity(0.28), lineWidth: 1)
                )
        }
        .accessibilityLabel("발음 듣기")
    }

    private var footer: some View {
        VStack(spacing: 16) {
            Text("5초 안에 뜻이 떠올랐나요?")
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.70))

            HStack(spacing: 12) {
                Button(action: onForgot) {
                    Text("기억 안 나요")
                        .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                        .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(DesignSystemAsset.white.swiftUIColor.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(DesignSystemAsset.white.swiftUIColor.opacity(0.28), lineWidth: 1)
                        )
                }

                Button(action: onRemembered) {
                    Text("떠올랐어요")
                        .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                        .foregroundStyle(DesignSystemAsset.game.swiftUIColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(DesignSystemAsset.white.swiftUIColor)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 40)
    }
}
