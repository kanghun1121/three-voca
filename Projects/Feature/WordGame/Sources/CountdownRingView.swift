import SwiftUI

import DesignSystem

struct CountdownRingView: View {
    let countdown: Int
    let progress: Double

    private let size: CGFloat = 68
    private let strokeWidth: CGFloat = 7

    var body: some View {
        ZStack {
            Circle()
                .stroke(DesignSystemAsset.white.swiftUIColor.opacity(0.18), lineWidth: strokeWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(DesignSystemAsset.white.swiftUIColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(countdown)")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 23))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
        }
        .frame(width: size, height: size)
    }
}
