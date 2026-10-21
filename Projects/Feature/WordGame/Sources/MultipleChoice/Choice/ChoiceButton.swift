import SwiftUI

import DesignSystem

struct ChoiceButton: View {
    let text: String
    let state: ChoiceButtonState
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .typography(DesignSystemTypography.Pretendard.bold18)
                .foregroundStyle(DesignSystemColor.Base.white)
                .frame(
                    maxWidth: .infinity,
                    minHeight: 64,
                    alignment: .leading
                )
                .padding(.horizontal, 22)
        }
        .background(backgroundColor)
        .clipShape(.rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(borderColor, lineWidth: borderWidth)
        }
        .overlay(alignment: .trailing) {
            if differentiateWithoutColor {
                if state == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DesignSystemColor.Status.positive)
                        .accessibilityHidden(true)
                        .padding(.trailing, 16)
                } else if state == .incorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DesignSystemColor.Status.negative)
                        .accessibilityHidden(true)
                        .padding(.trailing, 16)
                }
            }
        }
        .disabled(state != .idle)
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: state)
        .accessibilityLabel(accessibilityLabel)
    }

    private var backgroundColor: Color {
        switch state {
        case .idle:      DesignSystemColor.Base.white.opacity(0.05)
        case .correct:   DesignSystemColor.Status.positive.opacity(0.15)
        case .incorrect: DesignSystemColor.Status.negative.opacity(0.15)
        }
    }

    private var borderColor: Color {
        switch state {
        case .idle:      DesignSystemColor.Base.white.opacity(0.22)
        case .correct:   DesignSystemColor.Status.positive
        case .incorrect: DesignSystemColor.Status.negative
        }
    }

    private var borderWidth: Double {
        switch state {
        case .idle:                1
        case .correct, .incorrect: 2
        }
    }

    private var accessibilityLabel: String {
        switch state {
        case .idle:      text
        case .correct:   "\(text), 정답"
        case .incorrect: "\(text), 오답"
        }
    }
}
