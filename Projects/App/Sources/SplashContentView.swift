import SwiftUI

import DesignSystem

struct SplashContentView: View {
    var body: some View {
        ZStack {
            Image("LaunchImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()
                DotLoaderView()
                    .padding(.bottom, 60)
            }
        }
    }
}
