import SwiftUI

import DesignSystem
import FeatureWordGameInterface

public struct WordGameView: View {
    @Bindable private var viewModel: WordGameViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: WordGameViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            gameBackground

            if viewModel.isCompleted {
                completionView
            } else if let word = viewModel.currentWord {
                VStack(spacing: 0) {
                    header(word: word)
                    stageContent(word: word)
                }
            }
        }
        .task { viewModel.start() }
        .navigationBarHidden(true)
    }

    // MARK: - Background

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

    // MARK: - Header

    private func header(word: GameWord) -> some View {
        VStack(spacing: 0) {
            StageSegmentBar(currentStage: viewModel.currentStage.rawValue)
                .padding(.top, 6)

            HStack {
                Button(action: viewModel.dismissGame) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                        .frame(width: 40, height: 40)
                }
                .padding(.leading, 10)
                .accessibilityLabel("닫기")

                Spacer()

                Text(stageLabel)
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

    private var stageLabel: String {
        switch viewModel.currentStage {
        case .recognition: "인식"
        case .meaning: "뜻"
        case .spelling: "스펠링"
        case .pronunciation: "발음"
        }
    }

    // MARK: - Stage Content

    @ViewBuilder
    private func stageContent(word: GameWord) -> some View {
        switch viewModel.currentStage {
        case .recognition:
            RecognitionView(
                word: word,
                countdown: viewModel.recognitionCountdown,
                onRemembered: { viewModel.recognitionDidTap(remembered: true) },
                onForgot: { viewModel.recognitionDidTap(remembered: false) },
                onAudio: { }
            )

        case .meaning:
            MeaningView(
                word: word,
                choices: viewModel.meaningChoices,
                selectedIndex: viewModel.selectedMeaningIndex,
                correctIndex: viewModel.correctMeaningIndex,
                onSelect: viewModel.meaningDidSelect
            )

        case .spelling:
            SpellingView(
                word: word,
                input: $viewModel.spellingInput,
                onConfirm: viewModel.spellingDidConfirm
            )

        case .pronunciation:
            PronunciationView(
                word: word,
                isListening: viewModel.isMicListening,
                onMicTap: viewModel.micDidTap
            )
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)

            Text("게임 완료!")
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
}
