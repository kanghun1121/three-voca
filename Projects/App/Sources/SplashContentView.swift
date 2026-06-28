import SwiftUI

import DesignSystem

struct SplashContentView: View {
    let isVisible: Bool

    var body: some View {
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
}
