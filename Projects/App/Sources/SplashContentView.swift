import SwiftUI

import DesignSystem

struct SplashContentView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Text("DAILY VOCABULARY")
                    .font(.system(size: 14, weight: .bold))
                    .kerning(4.2)
                    .foregroundStyle(Color(red: 0, green: 0.4, blue: 1).opacity(0.55))

                Text("\(Text("3초 ").foregroundStyle(Color(red: 0.039, green: 0.039, blue: 0.047)))\(Text("영단어").foregroundStyle(Color(red: 0, green: 0.4, blue: 1)))")
                    .font(.system(size: 72, weight: .heavy))
                    .kerning(-3.2)
            }

            VStack {
                Spacer()
                DotLoaderView()
                    .padding(.bottom, 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
