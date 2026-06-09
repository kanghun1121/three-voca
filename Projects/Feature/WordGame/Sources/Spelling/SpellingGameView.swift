import SwiftUI

import DesignSystem
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

            switch viewModel.viewState {
            case .active, .correct, .incorrect:
                if let word = viewModel.currentWord {
                    SpellingActivePhaseView(
                        word: word,
                        slots: viewModel.slots,
                        viewState: viewModel.viewState,
                        onDismiss: viewModel.closeButtonTapped,
                        onFocusKeyboard: { isKeyboardFocused = true }
                    )
                }

            case .revealing:
                if let word = viewModel.currentWord {
                    SpellingRevealPhaseView(word: word, onDismiss: viewModel.closeButtonTapped)
                }

            case .completed:
                SpellingCompletedView()
            }

            // 시스템 키보드 진입점 — 화면에 보이지 않음
            TextField("", text: $viewModel.inputText)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .focused($isKeyboardFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(.asciiCapable)
        }
        .onAppear {
            viewModel.start()
            isKeyboardFocused = true
        }
        .onChange(of: viewModel.viewState) { _, state in
            switch state {
            case .revealing, .completed:
                isKeyboardFocused = false
            case .active:
                isKeyboardFocused = true
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
    let word: GameWord
    let slots: [SpellingViewModel.SlotState]
    let viewState: SpellingViewModel.ViewState
    let onDismiss: () -> Void
    let onFocusKeyboard: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SpellingGameHeader(onDismiss: onDismiss)

            SpellingView(word: word, slots: slots, viewState: viewState)
                .contentShape(Rectangle())
                .onTapGesture { onFocusKeyboard() }
        }
    }
}

// MARK: - 정답 공개 단계

private struct SpellingRevealPhaseView: View {
    let word: GameWord
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SpellingGameHeader(onDismiss: onDismiss)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Text(word.term)
                        .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 52))
                        .tracking(-0.03 * 52)
                        .foregroundStyle(DesignSystemAsset.white.swiftUIColor)

                    Text(word.pronunciation)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.65))
                        .padding(.top, 12)

                    Text(word.primaryMeaning)
                        .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(DesignSystemAsset.white.swiftUIColor.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(DesignSystemAsset.white.swiftUIColor.opacity(0.28), lineWidth: 1)
                        }
                        .padding(.top, 24)
                }

                Spacer()
            }
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
