import SwiftUI

struct HomeHeaderView: View {
    let streakDays: Int

    @ScaledMetric private var titleSize: CGFloat = 28

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            StreakBadge(days: streakDays)
            Text("오늘도 3초 안에\n떠올려볼까요?")
                .font(.system(size: titleSize, weight: .bold))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HomeHeaderView(streakDays: 7)
        .padding()
}

#Preview("다크 모드") {
    HomeHeaderView(streakDays: 7)
        .padding()
        .preferredColorScheme(.dark)
}
