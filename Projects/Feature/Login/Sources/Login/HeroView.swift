import SwiftUI

import DesignSystem

struct HeroView: View {
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width

            ZStack(alignment: .topLeading) {
                LinearGradient(
                    stops: [
                        .init(color: DesignSystemAsset.game100.swiftUIColor, location: 0),
                        .init(color: .white, location: 1)
                    ],
                    startPoint: UnitPoint(x: 0.28, y: 0),
                    endPoint: UnitPoint(x: 0.72, y: 1)
                )
                .ignoresSafeArea()

                FloatingWordCardView(word: "persevere", meaning: "끈기 있게 계속하다", tagKind: .know)
                    .rotationEffect(.degrees(-6))
                    .offset(x: 36, y: 86)

                FloatingWordCardView(word: "ambiguous", meaning: "모호한", tagKind: .time)
                    .rotationEffect(.degrees(5))
                    .offset(x: w - 220 - 28, y: 162)

                FloatingWordCardView(word: "profound", meaning: "깊은, 심오한", tagKind: .know)
                    .rotationEffect(.degrees(-3))
                    .offset(x: 44, y: 264)

                // 데코 점 a: top 100, right 60, 8pt, game 0.4
                Circle()
                    .fill(DesignSystemAsset.game.swiftUIColor.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .offset(x: w - 60 - 8, y: 100)

                // 데코 점 b: top 220, left 24, 6pt, primary 0.5
                Circle()
                    .fill(DesignSystemAsset.primary.swiftUIColor.opacity(0.5))
                    .frame(width: 6, height: 6)
                    .offset(x: 24, y: 220)

                // 데코 점 c: bottom 60, right 100, 10pt, cautionary 0.3
                Circle()
                    .fill(DesignSystemAsset.cautionary.swiftUIColor.opacity(0.3))
                    .frame(width: 10, height: 10)
                    .offset(x: w - 100 - 10, y: 460 - 60 - 10)
            }
        }
        .frame(height: 460)
        .clipped()
    }
}
