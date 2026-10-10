import SwiftUI

import DesignSystem

/// 최하단에서 벗어났을 때 채팅 목록 위에 띄우는 "최하단으로 이동" 원형 버튼.
struct ScrollToBottomButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.down")
                .typography(DesignSystemTypography.Pretendard.semiBold14)
                .foregroundStyle(DesignSystemColor.Foreground.muted)
                .frame(width: 36, height: 36)
                .background(DesignSystemColor.Background.elevated, in: .circle)
                .overlay {
                    Circle().stroke(DesignSystemColor.Border.default, lineWidth: 1)
                }
                .shadow(
                    color: DesignSystemColor.Foreground.strong.opacity(0.08),
                    radius: 4,
                    x: 0,
                    y: 2
                )
                // 시각 크기(36pt)와 레이아웃은 그대로 두고, 터치 영역만 44pt로 넓힌다.
                .frame(width: 44, height: 44)
                .contentShape(.rect)
                .padding(-4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("최하단으로 이동")
    }
}
