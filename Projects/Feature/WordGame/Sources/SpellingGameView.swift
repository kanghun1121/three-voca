import SwiftUI

import DesignSystem
import SwiftUINavigation

public struct SpellingGameView: View {
    @Bindable private var viewModel: SpellingViewModel

    public init(viewModel: SpellingViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            GameBackground()

            switch viewModel.viewState {
            case .active, .correct, .incorrect:
                if let word = viewModel.currentWord {
                    SpellingActivePhaseView(
                        word: word,
                        slots: viewModel.slots,
                        viewState: viewModel.viewState,
                        isConfirmEnabled: viewModel.isConfirmEnabled,
                        onDismiss: viewModel.closeButtonTapped,
                        onLetter: viewModel.letterTapped,
                        onDelete: viewModel.deleteTapped,
                        onConfirm: viewModel.confirmTapped
                    )
                }

            case .completed:
                SpellingCompletedView()
            }
        }
        .onAppear { viewModel.start() }
        .toolbar(.hidden, for: .navigationBar)
        .alert($viewModel.destination.alert) { action in
            viewModel.alertButtonTapped(action)
        }
    }
}

// MARK: - 활성 단계

private struct SpellingActivePhaseView: View {
    let word: GameWord
    let slots: [SpellingViewModel.SlotState]
    let viewState: SpellingViewModel.ViewState
    let isConfirmEnabled: Bool
    let onDismiss: () -> Void
    let onLetter: (Character) -> Void
    let onDelete: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SpellingGameHeader(onDismiss: onDismiss)

            SpellingView(word: word, slots: slots, viewState: viewState)

            SpellingKeyboardView(
                onLetter: onLetter,
                onDelete: onDelete,
                onConfirm: onConfirm,
                isConfirmEnabled: isConfirmEnabled
            )
        }
    }
}

// MARK: - 헤더

private struct SpellingGameHeader: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            StageSegmentBar(currentStage: 2)
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

                Text("스펠링")
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

private struct SpellingCompletedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)

            Text("스펠링 완료!")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 32))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
        }
    }
}
