import SwiftUI

import DesignSystem

struct HeadlineView: View {
    @ScaledMetric private var headlineSize: CGFloat = DesignSystemTypography.Pretendard.extraBold32.size

    var body: some View {
        let highlighted = Text("3초 안에").foregroundStyle(DesignSystemColor.Game.base)
        Text("단어를 \(highlighted)\n떠올리는 힘")
            .typography(DesignSystemTypography.Pretendard.extraBold32.scaled(to: CGFloat(headlineSize)))
            .foregroundStyle(DesignSystemColor.Foreground.strong)
    }
}
