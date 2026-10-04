import SwiftUI

import DesignSystem
import DomainInterface

import SwiftUINavigation

public struct SpellingGameView: View {
    @Bindable private var viewModel: SpellingViewModel
    @FocusState private var isKeyboardFocused: Bool

    public init(viewModel: SpellingViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            GameBackground()

            if let word = viewModel.currentWord {
                SpellingActivePhaseView(
                    word: word,
                    inputText: $viewModel.inputText,
                    isFocused: $isKeyboardFocused,
                    viewState: viewModel.viewState,
                    canSubmit: viewModel.canSubmit,
                    onSubmit: viewModel.submitButtonTapped,
                    onDismiss: viewModel.closeButtonTapped,
                    onSkip: viewModel.skipButtonTapped
                )
            }
        }
        .onAppear {
            viewModel.load()
            isKeyboardFocused = true
        }
        .onChange(of: viewModel.viewState) { _, state in
            switch state {
            case .revealing:
                isKeyboardFocused = false
            case .active:
                if !isKeyboardFocused { isKeyboardFocused = true }
            default:
                break
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert($viewModel.destination.alert) { action in
            viewModel.alertButtonTapped(action)
        }
    }
}

// MARK: - 활성 단계

private struct SpellingActivePhaseView: View {
    let word: Lesson.Word
    @Binding var inputText: String
    var isFocused: FocusState<Bool>.Binding
    let viewState: SpellingViewModel.ViewState
    let canSubmit: Bool
    let onSubmit: () -> Void
    let onDismiss: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SpellingGameHeader(onDismiss: onDismiss)

            SpellingView(
                word: word,
                inputText: $inputText,
                isFocused: isFocused,
                viewState: viewState,
                canSubmit: canSubmit,
                onSubmit: onSubmit,
                onSkip: onSkip
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

            SpellingHeaderRow(onDismiss: onDismiss)
        }
    }
}

private struct SpellingHeaderRow: View {
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

            Spacer().frame(width: 40)
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
    }
}
