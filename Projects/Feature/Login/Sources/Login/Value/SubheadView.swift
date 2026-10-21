import SwiftUI

import DesignSystem

struct SubheadView: View {
    @ScaledMetric private var subheadSize: CGFloat = DesignSystemTypography.Pretendard.regular14.size

    var body: some View {
        Text("시간 압박이 진짜 아는 단어를 가려냅니다.\n6,000개 어휘를 게임처럼 익혀보세요.")
            .typography(DesignSystemTypography.Content.loginSubhead.scaled(to: CGFloat(subheadSize)))
            .foregroundStyle(DesignSystemColor.Foreground.muted)
    }
}
