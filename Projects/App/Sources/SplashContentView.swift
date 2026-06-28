import SwiftUI

import DesignSystem

struct SplashContentView: View {
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image("LaunchImage")
                    .resizable()
                    .scaledToFit()
                Spacer()
            }

            VStack {
                Spacer()
                DotLoaderView()
                    .padding(.bottom, 60)
            }
        }
    }
}
