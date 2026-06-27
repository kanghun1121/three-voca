import SwiftUI

import DesignSystem

struct LaunchScreen: View {
    @State private var isVisible = false
    @State private var animate = false

    var body: some View {
        ZStack {
            DesignSystemAsset.background.swiftUIColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                wordmark
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 10)
                    .scaleEffect(isVisible ? 1 : 0.97)

                Spacer()

                dotLoader
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.timingCurve(0.3, 0, 0, 1, duration: 0.5)) {
                isVisible = true
            }
            animate = true
        }
    }

    private var wordmark: some View {
        VStack(spacing: 22) {
            Text("DAILY VOCABULARY")
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                .tracking(3.6)
                .foregroundStyle(DesignSystemAsset.primary.swiftUIColor.opacity(0.55))

            HStack(spacing: 0) {
                Text("쓰리")
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                Text("보카")
                    .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
            }
            .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 60))
            .tracking(-2.7)
        }
        .multilineTextAlignment(.center)
    }

    private var dotLoader: some View {
        HStack(spacing: 9) {
            dot(delay: 0)
            dot(delay: 0.16)
            dot(delay: 0.32)
        }
    }

    private func dot(delay: Double) -> some View {
        Circle()
            .fill(DesignSystemAsset.primary.swiftUIColor)
            .frame(width: 8, height: 8)
            .scaleEffect(animate ? 1.0 : 0.7)
            .opacity(animate ? 1.0 : 0.3)
            .animation(
                .easeInOut(duration: 0.65)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: animate
            )
    }
}
