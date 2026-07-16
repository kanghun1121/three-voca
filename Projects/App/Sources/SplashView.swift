import SwiftUI

import DesignSystem

struct SplashView: View {
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: DesignSystemAsset.splashGradientTop.swiftUIColor, location: 0),
                .init(color: DesignSystemAsset.splashGradientMid.swiftUIColor, location: 0.52),
                .init(color: DesignSystemAsset.splashGradientBottom.swiftUIColor, location: 1)
            ]),
            startPoint: UnitPoint(x: 0.26, y: -0.03),
            endPoint: UnitPoint(x: 0.74, y: 1.03)
        )
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            SplashContentView()
        }
    }
}
