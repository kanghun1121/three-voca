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

// MARK: - 선택지 버튼 상태

enum ChoiceButtonState {
    case idle
    case selected
    case correct
    case incorrect
}

// MARK: - 선택지 버튼

private struct ChoiceButton: View {
    let text: String
    let state: ChoiceButtonState
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                .tracking(-0.01 * 18)
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                .padding(.horizontal, 22)
        }
        .background(backgroundColor)
        .clipShape(.rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(borderColor, lineWidth: borderWidth)
        }
        .disabled(state != .idle)
        .animation(.easeInOut(duration: 0.2), value: state)
    }

    private var backgroundColor: Color {
        switch state {
        case .idle:
            return DesignSystemAsset.white.swiftUIColor.opacity(0.05)
        case .selected:
            return DesignSystemAsset.white.swiftUIColor.opacity(0.16)
        case .correct:
            return DesignSystemAsset.positive.swiftUIColor.opacity(0.15)
        case .incorrect:
            return DesignSystemAsset.cautionary.swiftUIColor.opacity(0.15)
        }
    }

    private var borderColor: Color {
        switch state {
        case .idle:
            return DesignSystemAsset.white.swiftUIColor.opacity(0.22)
        case .selected:
            return DesignSystemAsset.white.swiftUIColor
        case .correct:
            return DesignSystemAsset.positive.swiftUIColor
        case .incorrect:
            return DesignSystemAsset.cautionary.swiftUIColor
        }
    }

    private var borderWidth: Double {
        switch state {
        case .idle:
            return 1
        case .selected, .correct, .incorrect:
            return 2
        }
    }
}
