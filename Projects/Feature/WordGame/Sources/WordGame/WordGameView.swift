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
                ZStack {
                    GameBackground()
                    ProgressView()
                        .tint(DesignSystemAsset.white.swiftUIColor)
                }

            case .recognition(let vm):
                RecognitionGameView(viewModel: vm)
                    .transition(.opacity)

            case .multipleChoice(let vm):
                MultipleChoiceGameView(viewModel: vm)
                    .transition(.opacity)

            case .spelling(let vm):
                SpellingGameView(viewModel: vm)
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
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.70))
                .multilineTextAlignment(.center)

            Button(action: onDismiss) {
                Text("닫기")
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                    .foregroundStyle(DesignSystemAsset.game.swiftUIColor)
                    .frame(width: 200, height: 60)
                    .background(DesignSystemAsset.white.swiftUIColor)
                    .clipShape(.rect(cornerRadius: 18))
            }
        }
        .padding(.horizontal, 32)
    }
}
