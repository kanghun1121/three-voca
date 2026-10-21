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
                .stroke(DesignSystemColor.Base.white.opacity(0.18), lineWidth: strokeWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(DesignSystemColor.Base.white, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(countdown)")
                .typography(DesignSystemTypography.Pretendard.extraBold23)
                .foregroundStyle(DesignSystemColor.Base.white)
        }
        .frame(width: size, height: size)
    }
}
