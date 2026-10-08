import SwiftUI

import DesignSystem

public struct WordGameView: View {
    @Bindable private var viewModel: WordGameViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: WordGameViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            switch viewModel.activeStage {
            case .loading:
                WordGameLoadingView()

            case .launch(let onStart):
                WordGameLaunchView(onStart: onStart)
                    .transition(.opacity)

            case .recognition(let vm):
                RecognitionGameView(viewModel: vm)
                    .transition(.opacity)

            case .stageEnd(let title, let onContinue):
                StageEndView(title: title, onContinue: onContinue)
                    .transition(.opacity)

            case .multipleChoice(let vm):
                MultipleChoiceGameView(viewModel: vm)
                    .transition(.opacity)

            case .spelling(let vm):
                SpellingGameView(viewModel: vm)
                    .transition(.opacity)

            case .gameComplete(let wordCount, let onDismiss):
                GameCompleteView(wordCount: wordCount, onDismiss: onDismiss)
                    .transition(.opacity)

            case .error(let message):
                ZStack {
                    GameBackground()
                    GameErrorView(message: message, onDismiss: { dismiss() })
                }
            }
        }
        .task { await viewModel.load() }
        .onChange(of: viewModel.dismiss) {
            if viewModel.dismiss { dismiss() }
        }
    }
}

// MARK: - 에러 화면

private struct GameErrorView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .typography(DesignSystemTypography.Pretendard.medium16)
                .foregroundStyle(DesignSystemColor.Base.white.opacity(0.70))
                .multilineTextAlignment(.center)

            Button(action: onDismiss) {
                Text("닫기")
                    .typography(DesignSystemTypography.Pretendard.bold16)
                    .foregroundStyle(DesignSystemColor.Game.base)
                    .frame(width: 200, height: 60)
                    .background(DesignSystemColor.Base.white)
                    .clipShape(.rect(cornerRadius: 18))
            }
        }
        .padding(.horizontal, 32)
    }
}
