import SwiftUI

import DesignSystem
import DomainInterface

struct SpellingView: View {
    let word: Lesson.Word
    @Binding var inputText: String
    var isFocused: FocusState<Bool>.Binding
    let viewState: SpellingViewModel.ViewState
    let canSubmit: Bool
    let onSubmit: () -> Void
    let onSkip: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                Text("이 뜻의 영어 단어는?")
                    .typography(DesignSystemTypography.Pretendard.regular14)
                    .foregroundStyle(DesignSystemColor.Base.white.opacity(0.55))

                Text(word.primaryMeaning)
                    .typography(DesignSystemTypography.Pretendard.bold26)
                    .foregroundStyle(DesignSystemColor.Base.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.bottom, 36)

                SpellingInputField(
                    text: $inputText,
                    isFocused: isFocused,
                    viewState: viewState,
                    reduceMotion: reduceMotion,
                    onSubmit: onSubmit
                )

                // 제출·건너뛰기 버튼 (입력 중에만 표시)
                if viewState == .active {
                    SpellingSubmitButton(isEnabled: canSubmit, action: onSubmit)
                        .padding(.top, 16)

                    Button("건너뛰기", action: onSkip)
                        .typography(DesignSystemTypography.Pretendard.regular14)
                        .foregroundStyle(DesignSystemColor.Base.white.opacity(0.40))
                        .padding(.top, 20)
                }

                // 오답 시 정답 카드
                if viewState == .revealing {
                    Text(word.term)
                        .typography(DesignSystemTypography.Pretendard.semiBold18)
                        .foregroundStyle(DesignSystemColor.Base.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(DesignSystemColor.Base.white.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(DesignSystemColor.Base.white.opacity(0.28), lineWidth: 1)
                        }
                        .padding(.top, 24)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, 24)
            .animation(.easeOut(duration: 0.2), value: viewState == .revealing)

            Spacer()
        }
    }
}

// MARK: - 입력 필드

/// 시스템 TextField로 입력을 직접 받는 필드. 깜빡이는 커서는 시스템 캐럿(tint)을 쓴다.
private struct SpellingInputField: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let viewState: SpellingViewModel.ViewState
    let reduceMotion: Bool
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            TextField("", text: $text)
                .typography(DesignSystemTypography.Mono.bold22)
                .foregroundStyle(DesignSystemColor.Base.white)
                .tint(DesignSystemColor.Base.white)
                .focused(isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(.asciiCapable)
                .submitLabel(.done)
                .onSubmit(onSubmit)
                .disabled(viewState != .active)

            if viewState == .active && !text.isEmpty {
                Button("전체 지우기", systemImage: "xmark.circle.fill") {
                    text = ""
                }
                .labelStyle(.iconOnly)
                .typography(DesignSystemTypography.Pretendard.regular20)
                .foregroundStyle(DesignSystemColor.Base.white.opacity(0.55))
            }
        }
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .padding(.horizontal, 20)
            .background(fillColor, in: .rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: 2)
            }
            .modifier(ShakeModifier(trigger: viewState == .incorrect || viewState == .revealing, reduceMotion: reduceMotion))
    }

    private var fillColor: Color {
        switch viewState {
        case .correct:
            DesignSystemColor.Status.positive.opacity(0.20)
        case .incorrect, .revealing:
            DesignSystemColor.Status.negative.opacity(0.20)
        case .active:
            DesignSystemColor.Base.white.opacity(0.16)
        }
    }

    private var borderColor: Color {
        switch viewState {
        case .correct:
            DesignSystemColor.Status.positive.opacity(0.55)
        case .incorrect, .revealing:
            DesignSystemColor.Status.negative.opacity(0.55)
        case .active:
            DesignSystemColor.Base.white.opacity(0.28)
        }
    }
}

// MARK: - 제출 버튼

private struct SpellingSubmitButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button("제출", action: action)
            .typography(DesignSystemTypography.Pretendard.bold16)
            .foregroundStyle(DesignSystemColor.Base.white.opacity(isEnabled ? 1 : 0.40))
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(DesignSystemColor.Base.white.opacity(isEnabled ? 0.28 : 0.10), in: .rect(cornerRadius: 14))
            .disabled(!isEnabled)
    }
}

// MARK: - 쉐이크 애니메이션

private struct ShakeModifier: ViewModifier {
    let trigger: Bool
    let reduceMotion: Bool

    @State private var offset: Double = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) {
                guard trigger, !reduceMotion else { return }
                Task {
                    withAnimation(.interpolatingSpring(stiffness: 600, damping: 8)) { offset = 8 }
                    try? await Task.sleep(for: .milliseconds(80))
                    withAnimation(.interpolatingSpring(stiffness: 600, damping: 8)) { offset = -8 }
                    try? await Task.sleep(for: .milliseconds(80))
                    withAnimation(.interpolatingSpring(stiffness: 600, damping: 10)) { offset = 0 }
                }
            }
    }
}
