import SwiftUI

import DesignSystem

struct GameBackground: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: DesignSystemColor.Game.base, location: 0),
                .init(color: DesignSystemColor.Game.dark, location: 0.55),
                .init(color: DesignSystemColor.Game.deep, location: 1),
            ],
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
    }
}
