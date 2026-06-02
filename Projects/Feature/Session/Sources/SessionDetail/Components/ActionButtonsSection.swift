import DesignSystem
import SwiftUI

struct ActionButtonsSection: View {
    let onVocabularyListTapped: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Button(action: {}) {
                Label("학습 시작 — 4-Phase 게임", systemImage: "play.fill")
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 17))
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(DesignSystemAsset.game.swiftUIColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            Button(action: onVocabularyListTapped) {
                Label("단어 보기 (게임 없이 깊이 학습)", systemImage: "book")
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 17))
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(DesignSystemAsset.white.swiftUIColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(DesignSystemAsset.border.swiftUIColor, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}
