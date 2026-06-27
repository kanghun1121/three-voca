import SwiftUI

import DesignSystem

struct DotView: View {
    let delay: Double

    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Circle()
            .fill(DesignSystemAsset.primary.swiftUIColor)
            .frame(width: 8, height: 8)
            .scaleEffect(isAnimating ? 1.0 : 0.7)
            .opacity(reduceMotion ? 0.5 : (isAnimating ? 1.0 : 0.3))
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 0.65)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isAnimating
            )
            .onAppear {
                guard !reduceMotion else { return }
                isAnimating = true
            }
    }
}
