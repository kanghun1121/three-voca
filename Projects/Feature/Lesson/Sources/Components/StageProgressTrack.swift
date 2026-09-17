import SwiftUI

import DesignSystem

/// 진도 트랙(track+fill pill). 목록 행(2px) / 상세 히어로(4px) 양쪽에서 높이·색만 바꿔 재사용한다.
struct StageProgressTrack: View {
    let ratio: Double
    let fillColor: Color
    let height: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(DesignSystemAsset.progressTrack.swiftUIColor)
            Capsule()
                .fill(fillColor)
                .containerRelativeFrame(.horizontal) { width, _ in
                    width * max(0, min(1, ratio))
                }
        }
        .frame(height: height)
    }
}
