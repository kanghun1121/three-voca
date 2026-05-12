import SwiftUI

struct FilledCircle: View {
    let color: Color
    let symbol: String

    @ScaledMetric private var circleSize: CGFloat = 32
    @ScaledMetric private var symbolSize: CGFloat = 14

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: circleSize, height: circleSize)
            Image(systemName: symbol)
                .font(.system(size: symbolSize, weight: .bold))
                .foregroundStyle(.white)
                .accessibilityHidden(true)
        }
    }
}
