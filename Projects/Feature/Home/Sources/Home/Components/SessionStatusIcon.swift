import SwiftUI

struct SessionStatusIcon: View {
    let kind: SessionIconKind

    var body: some View {
        switch kind {
        case .completedHigh:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .accessibilityHidden(true)
        case .completedLow:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
                .accessibilityHidden(true)
        case .notStarted:
            Image(systemName: "circle")
                .foregroundStyle(.gray)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        SessionStatusIcon(kind: .completedHigh)
        SessionStatusIcon(kind: .completedLow)
        SessionStatusIcon(kind: .notStarted)
    }
    .padding()
}
