import SwiftUI

struct StreakBadge: View {
    let days: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.caption)
                .foregroundStyle(HomeColors.brandOrange)
                .accessibilityHidden(true)
            Text("연속 학습 \(days)일째")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
