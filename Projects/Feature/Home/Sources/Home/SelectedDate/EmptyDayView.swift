import SwiftUI

import DesignSystem

struct EmptyDayView: View {
    let isFuture: Bool
    let onGoToToday: () -> Void

    private var subtitle: String {
        isFuture ? "아직 오지 않은 날이에요" : "쉬어간 날도 기록의 일부예요"
    }

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 4) {
                Text("학습 기록이 없는 날이에요")
                    .typography(DesignSystemTypography.Home.emptyDayTitle)
                    .foregroundStyle(DesignSystemColor.Foreground.default)
                Text(subtitle)
                    .typography(DesignSystemTypography.Home.emptyDaySubtext)
                    .foregroundStyle(DesignSystemColor.Foreground.subtle)
            }
            if !isFuture {
                Button("오늘 학습으로 이동", action: onGoToToday)
                    .typography(DesignSystemTypography.Pretendard.semiBold13)
                    .foregroundStyle(DesignSystemColor.Accent.selectedBlueText)
                    .padding(.vertical, 9)
                    .padding(.horizontal, 18)
                    .frame(minHeight: 44)
                    .overlay {
                        Capsule().strokeBorder(DesignSystemColor.Accent.selectedBlue, lineWidth: 1)
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
