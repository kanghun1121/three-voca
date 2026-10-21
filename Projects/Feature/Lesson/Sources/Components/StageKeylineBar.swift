import SwiftUI

/// 단계 색상 키라인 바. 목록 행(3px×32) / 상세 히어로 칩(6px) 양쪽에서 색·크기만 바꿔 재사용한다.
struct StageKeylineBar: View {
    let color: Color
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: width, height: height)
    }
}
