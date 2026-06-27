import SwiftUI

import DesignSystem

struct LaunchScreen: View {
    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            DesignSystemAsset.background.swiftUIColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                WordmarkView()
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 10)
                    .scaleEffect(isVisible ? 1 : 0.97)

                Spacer()

                DotLoaderView()
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            if reduceMotion {
                isVisible = true
            } else {
                withAnimation(.timingCurve(0.3, 0, 0, 1, duration: 0.5)) {
                    isVisible = true
                }
            }
        }
    }
}
