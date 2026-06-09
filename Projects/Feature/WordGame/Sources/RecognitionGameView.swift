import SwiftUI

import DesignSystem
import FeatureWordGameInterface

public struct RecognitionGameView: View {
    @Bindable private var viewModel: RecognitionViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: RecognitionViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            gameBackground

            switch viewModel.phase {
            case .loading:
                ProgressView()
                    .tint(DesignSystemAsset.white.swiftUIColor)

            case .active, .revealing:
                if let word = viewModel.currentWord {
                    VStack(spacing: 0) {
                        header
                        RecognitionView(
                            word: word,
                            countdown: viewModel.countdown,
                            isRevealing: viewModel.phase == .revealing,
                            onRemembered: viewModel.didTapRemembered,
                            onForgot: viewModel.didTapForgot,
                            onAudio: { Task { await viewModel.didTapAudio() } }
                        )
                    }
                    .animation(.easeInOut(duration: 0.2), value: viewModel.phase == .revealing)
                }

            case .completed:
                completedView

            case .error(let message):
                errorView(message: message)
            }
        }
        .task { await viewModel.start() }
        .navigationBarHidden(true)
    }

    // MARK: - 배경

    private var gameBackground: some View {
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

    // MARK: - 헤더

    private var header: some View {
        VStack(spacing: 0) {
            StageSegmentBar(currentStage: 0)
                .padding(.top, 6)

            HStack {
                Button(action: viewModel.dismiss) {
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

    private var completedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)

            Text("완료!")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 32))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)

            Button(action: dismiss.callAsFunction) {
                Text("닫기")
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                    .foregroundStyle(DesignSystemAsset.game.swiftUIColor)
                    .frame(width: 200, height: 60)
                    .background(DesignSystemAsset.white.swiftUIColor)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    // MARK: - 에러 화면

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.70))
                .multilineTextAlignment(.center)

            Button(action: dismiss.callAsFunction) {
                Text("닫기")
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                    .foregroundStyle(DesignSystemAsset.game.swiftUIColor)
                    .frame(width: 200, height: 60)
                    .background(DesignSystemAsset.white.swiftUIColor)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
        .padding(.horizontal, 32)
    }
}
