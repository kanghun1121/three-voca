import SwiftUI

import DesignSystem

struct SplashView: View {
    var body: some View {
        ZStack {
            DesignSystemColor.Base.white
                .ignoresSafeArea()

            SplashContentView()
        }
    }
}
