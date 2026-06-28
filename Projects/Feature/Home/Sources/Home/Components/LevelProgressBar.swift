import SwiftUI

import DesignSystem

struct LevelProgressBar: View {
    let progressRatio: Double
    let status: LevelStatus
    let levelColor: Color

    // 비활성 진행바 색상 #C7C9CE
    private let inactiveColor = Color(red: 199/255, green: 201/255, blue: 206/255)

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(DesignSystemAsset.progressTrack.swiftUIColor)
            RoundedRectangle(cornerRadius: 4)
                .fill(status == .notStarted ? inactiveColor : levelColor)
                .scaleEffect(
                    x: max(0.03, min(1, progressRatio)),
                    anchor: .leading
                )
        }
        .frame(height: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}
