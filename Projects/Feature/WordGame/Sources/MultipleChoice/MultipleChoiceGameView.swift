import SwiftUI

import DesignSystem
import SwiftUINavigation

public struct MultipleChoiceGameView: View {
    @Bindable private var viewModel: MultipleChoiceViewModel

    public init(viewModel: MultipleChoiceViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            GameBackground()

            switch viewModel.viewState {
            case .active, .pendingReveal, .revealed:
                if let word = viewModel.currentWord {
                    MultipleChoiceActivePhaseView(
                        word: word,
                        choices: viewModel.choices,
                        viewState: viewModel.viewState,
                        wordIndex: viewModel.wordIndex,
                        totalWords: viewModel.totalWords,
                        isReviewRound: viewModel.isReviewRound,
                        onDismiss: viewModel.closeButtonTapped,
                        onChoiceTap: viewModel.choiceTapped
                    )
                }

            case .completed:
                MultipleChoiceCompletedView()
            }
        }
        .onAppear { viewModel.load() }
        .toolbar(.hidden, for: .navigationBar)
        .alert($viewModel.destination.alert) { action in
            viewModel.alertButtonTapped(action)
        }
    }
}

// MARK: - 활성/공개 단계

private struct MultipleChoiceActivePhaseView: View {
    let word: GameWord
    let choices: [String]
    let viewState: MultipleChoiceViewModel.ViewState
    let wordIndex: Int
    let totalWords: Int
    let isReviewRound: Bool
    let onDismiss: () -> Void
    let onChoiceTap: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            MultipleChoiceGameHeader(onDismiss: onDismiss)
            MultipleChoiceView(
                word: word,
                choices: choices,
                viewState: viewState,
                onChoiceTap: onChoiceTap
            )
        }
    }
}

// MARK: - 헤더

private struct MultipleChoiceGameHeader: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            StageSegmentBar(currentStage: 1)
                .padding(.top, 6)

            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                        .frame(width: 40, height: 40)
                }
                .padding(.leading, 10)
                .accessibilityLabel("닫기")

                Spacer()

                Text("뜻")
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .tracking(0.12 * 12)
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.70))

                Spacer()

                Spacer().frame(width: 40)
            }
            .padding(.horizontal, 8)
            .padding(.top, 10)
        }
    }
}

// MARK: - 완료 화면

private struct MultipleChoiceCompletedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)

            Text("뜻 확인 완료!")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 32))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
        }
    }
}
