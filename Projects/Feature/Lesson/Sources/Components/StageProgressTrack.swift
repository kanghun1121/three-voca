import SwiftUI

import DesignSystem

/// 진도 트랙(track+fill pill). 목록 행(2px) / 상세 히어로(4px) 양쪽에서 높이·색만 바꿔 재사용한다.
struct StageProgressTrack: View {
    let ratio: Double
    let fillColor: Color
    let height: CGFloat

    var body: some View {
        Capsule()
            .fill(DesignSystemColor.Stage.progressTrack)
            .overlay(alignment: .leading) {
                // 채움 폭은 화면이 아니라 트랙 자신의 폭 기준이어야 한다.
                GeometryReader { proxy in
                    Capsule()
                        .fill(fillColor)
                        .frame(width: proxy.size.width * max(0, min(1, ratio)))
                }
            }
            .frame(height: height)
    }
}
