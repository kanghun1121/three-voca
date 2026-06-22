import SwiftUI

import DesignSystem

struct PulsingDot: View {
    let delay: Double

    @State private var isReady = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if reduceMotion {
                baseCircle.opacity(0.55)
            } else if isReady {
                PhaseAnimator(DotPhase.allCases) { phase in
                    baseCircle
                        .scaleEffect(phase == .atPeak ? 1.0 : 0.62)
                        .opacity(phase == .atPeak ? 1.0 : 0.28)
                } animation: { phase in
                    switch phase {
                    case .atMin:  .linear(duration: 0.375)
                    case .atPeak: .easeInOut(duration: 0.4375)
                    case .atHold: .easeInOut(duration: 0.4375)
                    }
                }
            } else {
                baseCircle.scaleEffect(0.62).opacity(0.28)
            }
        }
        .task {
            if delay > 0 { try? await Task.sleep(for: .seconds(delay)) }
            isReady = true
        }
    }

    private var baseCircle: some View {
        Circle()
            .fill(DesignSystemAsset.primary.swiftUIColor)
            .frame(width: 12, height: 12)
    }
}
