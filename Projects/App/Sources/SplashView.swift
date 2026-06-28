import SwiftUI

import DesignSystem

struct SplashView: View {
    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            DesignSystemAsset.background.swiftUIColor
                .ignoresSafeArea()

            SplashContentView(isVisible: isVisible)
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
