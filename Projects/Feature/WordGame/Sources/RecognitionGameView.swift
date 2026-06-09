import SwiftUI

import DesignSystem
import SwiftUINavigation

public struct RecognitionGameView: View {
    @Bindable private var viewModel: RecognitionViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: RecognitionViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            GameBackground()

            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .tint(DesignSystemAsset.white.swiftUIColor)

            case .active, .revealing:
                if let word = viewModel.currentWord {
                    RecognitionActivePhaseView(
                        word: word,
                        isRevealing: viewModel.viewState == .revealing,
                        countdown: viewModel.countdown,
                        ringProgress: viewModel.ringProgress,
                        onDismiss: viewModel.closeButtonTapped,
                        onRemembered: viewModel.rememberedButtonTapped,
                        onForgot: viewModel.forgotButtonTapped
                    )
                }

            case .completed:
                RecognitionCompletedView(onDismiss: viewModel.doneButtonTapped)

            case .error(let message):
                RecognitionErrorView(message: message, onDismiss: viewModel.doneButtonTapped)
            }
        }
        .task { await viewModel.load() }
        .onChange(of: viewModel.dismiss) {
            if viewModel.dismiss { dismiss() }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert($viewModel.destination.alert) { action in
            viewModel.alertButtonTapped(action)
        }
    }
}

// MARK: - 배경

private struct GameBackground: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: DesignSystemAsset.game.swiftUIColor, location: 0),
                .init(color: DesignSystemAsset.gameDark.swiftUIColor, location: 0.55),
                .init(color: DesignSystemAsset.gameDeep.swiftUIColor, location: 1),
            ],
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
    }
}

// MARK: - 활성/공개 단계

private struct RecognitionActivePhaseView: View {
    let word: GameWord
    let isRevealing: Bool
    let countdown: Int
    let ringProgress: Double
    let onDismiss: () -> Void
    let onRemembered: () -> Void
    let onForgot: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            RecognitionGameHeader(onDismiss: onDismiss)
            RecognitionView(
                word: word,
                countdown: countdown,
                ringProgress: ringProgress,
                isRevealing: isRevealing,
                onRemembered: onRemembered,
                onForgot: onForgot
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isRevealing)
    }
}

// MARK: - 헤더

private struct RecognitionGameHeader: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            StageSegmentBar(currentStage: 0)
                .padding(.top, 6)
            RecognitionCloseRow(onDismiss: onDismiss)
        }
    }
}

private struct RecognitionCloseRow: View {
    let onDismiss: () -> Void

    var body: some View {
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

            Text("인식")
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

// MARK: - 완료 화면

private struct RecognitionCompletedView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)

            Text("완료!")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 32))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)

            Button(action: onDismiss) {
                Text("닫기")
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                    .foregroundStyle(DesignSystemAsset.game.swiftUIColor)
                    .frame(width: 200, height: 60)
                    .background(DesignSystemAsset.white.swiftUIColor)
                    .clipShape(.rect(cornerRadius: 18))
            }
        }
    }
}

// MARK: - 에러 화면

private struct RecognitionErrorView: View {
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
