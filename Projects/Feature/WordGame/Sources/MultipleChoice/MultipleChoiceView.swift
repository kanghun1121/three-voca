import SwiftUI

import DesignSystem

struct MultipleChoiceView: View {
    let word: GameWord
    let choices: [String]
    let viewState: MultipleChoiceViewModel.ViewState

    let onChoiceTap: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 10) {
                Text(word.term)
                    .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 40))
                    .tracking(-0.03 * 40)
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                    .multilineTextAlignment(.center)

                Text("알맞은 뜻을 고르세요")
                    .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                    .tracking(0.04 * 14)
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.55))
            }
            .padding(.horizontal, 28)

            Spacer()

            VStack(spacing: 12) {
                ForEach(choices, id: \.self) { choice in
                    ChoiceButton(
                        text: choice,
                        state: choiceButtonState(for: choice),
                        onTap: { onChoiceTap(choice) }
                    )
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 40)
        }
    }

    private func choiceButtonState(for choice: String) -> ChoiceButtonState {
        switch viewState {
        case .active:
            return .idle
        case .pendingReveal(let selected):
            return choice == selected ? .selected : .idle
        case .revealed(let selected):
            let correct = word.primaryMeaning
            if choice == correct {
                return .correct
            } else if choice == selected {
                return .incorrect
            }
            return .idle
        case .completed:
            return .idle
        }
    }
}
