import SwiftUI

struct SessionStatusIcon: View {
    let kind: SessionIconKind

    @ScaledMetric private var circleSize: CGFloat = 32

    var body: some View {
        switch kind {
        case .completedHigh, .completedLow:
            FilledCircle(color: HomeColors.brandGreen, symbol: "checkmark")
        case .notStarted:
            Circle()
                .strokeBorder(HomeColors.emptyRingStroke, lineWidth: 1.5)
                .frame(width: circleSize, height: circleSize)
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

#Preview("다크 모드") {
    HStack(spacing: 16) {
        SessionStatusIcon(kind: .completedHigh)
        SessionStatusIcon(kind: .completedLow)
        SessionStatusIcon(kind: .notStarted)
    }
    .padding()
    .preferredColorScheme(.dark)
}
