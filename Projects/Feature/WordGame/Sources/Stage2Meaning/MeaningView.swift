import SwiftUI

import DesignSystem
import FeatureWordGameInterface

struct MeaningView: View {
    let word: GameWord
    let choices: [String]
    let selectedIndex: Int?
    let correctIndex: Int?
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(word.term)
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 52))
                .tracking(-0.03 * 52)
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                .padding(.bottom, 8)

            Text("알맞은 뜻을 고르세요")
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.70))

            Spacer()

            choiceList

            Spacer().frame(height: 40)
        }
        .padding(.horizontal, 22)
    }

    private var choiceList: some View {
        VStack(spacing: 12) {
            ForEach(choices.indices, id: \.self) { index in
                choiceButton(index: index, text: choices[index])
            }
        }
    }

    private func choiceButton(index: Int, text: String) -> some View {
        Button {
            onSelect(index)
        } label: {
            Text(text)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(foregroundColor(for: index))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 60)
                .padding(.horizontal, 16)
                .background(backgroundColor(for: index))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(borderColor(for: index), lineWidth: 1)
                )
        }
        .disabled(selectedIndex != nil)
    }

    private func foregroundColor(for index: Int) -> Color {
        guard let selected = selectedIndex else {
            return DesignSystemAsset.white.swiftUIColor
        }
        if index == correctIndex {
            return DesignSystemAsset.game.swiftUIColor
        }
        return DesignSystemAsset.white.swiftUIColor.opacity(index == selected ? 1 : 0.4)
    }

    private func backgroundColor(for index: Int) -> Color {
        guard selectedIndex != nil else {
            return DesignSystemAsset.white.swiftUIColor.opacity(0.08)
        }
        if index == correctIndex {
            return DesignSystemAsset.white.swiftUIColor
        }
        return DesignSystemAsset.white.swiftUIColor.opacity(0.08)
    }

    private func borderColor(for index: Int) -> Color {
        guard selectedIndex != nil else {
            return DesignSystemAsset.white.swiftUIColor.opacity(0.28)
        }
        if index == correctIndex {
            return .clear
        }
        return DesignSystemAsset.white.swiftUIColor.opacity(0.28)
    }
}
