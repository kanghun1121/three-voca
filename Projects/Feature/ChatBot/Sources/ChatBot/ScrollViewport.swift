import SwiftUI

/// 스크롤 뷰의 크기와, 그 시점에 최하단 근처였는지를 함께 담은 스냅샷.
/// 크기가 바뀌기 직전 스냅샷과 비교해, 키보드로 뷰포트가 줄어드는 순간을 판별한다.
struct ScrollViewport: Equatable {
    let height: CGFloat
    let isNearBottom: Bool

    init(geometry: ScrollGeometry, threshold: CGFloat) {
        height = geometry.containerSize.height
        isNearBottom = geometry.contentOffset.y + geometry.containerSize.height
            >= geometry.contentSize.height - threshold
    }

    /// 직전 상태(`previous`)가 최하단 근처였는데 뷰포트가 줄어들었는지. 키보드가 올라올 때 해당한다.
    func shouldKeepBottom(after previous: ScrollViewport) -> Bool {
        height < previous.height && previous.isNearBottom
    }
}
