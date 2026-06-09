import SwiftUI

import DesignSystem

struct AudioWaveformView: View {
    let isAnimating: Bool

    private let barCount = 20
    @State private var phases: [Double] = (0..<20).map { Double($0) * 0.3 }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(DesignSystemAsset.white.swiftUIColor)
                    .frame(width: 3, height: barHeight(for: index))
                    .animation(
                        isAnimating
                        ? .easeInOut(duration: 0.5 + Double(index % 5) * 0.1)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.05)
                        : .default,
                        value: isAnimating
                    )
            }
        }
        .frame(height: 48)
    }

    private func barHeight(for index: Int) -> CGFloat {
        if !isAnimating {
            return 4 + CGFloat((index % 5)) * 4
        }
        let base: CGFloat = 8
        let amplitude: CGFloat = 28
        let phase = phases[index]
        return base + amplitude * CGFloat(abs(sin(phase)))
    }
}
