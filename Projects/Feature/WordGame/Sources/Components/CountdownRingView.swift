import SwiftUI

import DesignSystem

struct CountdownRingView: View {
    let value: Int
    let total: Int

    private let size: CGFloat = 68
    private let strokeWidth: CGFloat = 7

    private var progress: CGFloat {
        total > 0 ? CGFloat(value) / CGFloat(total) : 0
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    DesignSystemAsset.white.swiftUIColor.opacity(0.18),
                    lineWidth: strokeWidth
                )

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    DesignSystemAsset.white.swiftUIColor,
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            Text("\(value)")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 23))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
        }
        .frame(width: size, height: size)
    }
}
