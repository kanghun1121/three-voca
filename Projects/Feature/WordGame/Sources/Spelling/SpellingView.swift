import SwiftUI

import DesignSystem

struct SpellingView: View {
    let word: GameWord
    let slots: [SpellingViewModel.SlotState]
    let viewState: SpellingViewModel.ViewState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                Text("이 뜻의 영어 단어는?")
                    .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .tracking(0.04 * 14)
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.55))

                Text(word.primaryMeaning)
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 26))
                    .tracking(-0.012 * 26)
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.bottom, 36)

                SpellingSlotRow(slots: slots, viewState: viewState, reduceMotion: reduceMotion)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

// MARK: - 슬롯 행

struct SpellingSlotRow: View {
    let slots: [SpellingViewModel.SlotState]
    let viewState: SpellingViewModel.ViewState
    let reduceMotion: Bool

    var body: some View {
        HStack(spacing: 7) {
            ForEach(Array(slots.enumerated()), id: \.offset) { index, slot in
                SpellingSlotCell(slot: slot, viewState: viewState)
            }
        }
        .modifier(ShakeModifier(trigger: viewState == .incorrect, reduceMotion: reduceMotion))
    }
}

// MARK: - 슬롯 셀

private struct SpellingSlotCell: View {
    let slot: SpellingViewModel.SlotState
    let viewState: SpellingViewModel.ViewState

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(fillColor)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 2)
                }

            if case .filled(let char) = slot {
                Text(String(char).uppercased())
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .tracking(-0.01 * 22)
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
            } else if case .hint(let char) = slot {
                Text(String(char).uppercased())
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .tracking(-0.01 * 22)
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.90))
            }
        }
        .frame(width: 30, height: 42)
        .scaleEffect(scaleValue)
        .animation(.spring(duration: 0.12), value: slot)
    }

    private var fillColor: Color {
        if case .hint = slot {
            return DesignSystemAsset.white.swiftUIColor.opacity(0.22)
        }
        switch viewState {
        case .correct:
            return DesignSystemAsset.white.swiftUIColor.opacity(0.28)
        case .incorrect:
            return DesignSystemAsset.negative.swiftUIColor.opacity(0.20)
        default:
            if case .filled = slot {
                return DesignSystemAsset.white.swiftUIColor.opacity(0.16)
            }
            return Color.clear
        }
    }

    private var borderColor: Color {
        if case .hint = slot {
            return DesignSystemAsset.white.swiftUIColor.opacity(0.50)
        }
        switch viewState {
        case .correct:
            return DesignSystemAsset.white.swiftUIColor.opacity(0.55)
        case .incorrect:
            return DesignSystemAsset.negative.swiftUIColor.opacity(0.55)
        default:
            if case .cursor = slot {
                return DesignSystemAsset.white.swiftUIColor
            }
            return DesignSystemAsset.white.swiftUIColor.opacity(0.18)
        }
    }

    private var scaleValue: Double {
        if case .filled = slot { return 1.0 }
        return 1.0
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
