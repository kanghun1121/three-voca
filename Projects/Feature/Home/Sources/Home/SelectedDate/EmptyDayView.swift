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
            ZStack {
                Circle()
                    .fill(DesignSystemColor.Background.muted)
                    .frame(width: 44, height: 44)
                Circle()
                    .strokeBorder(
                        DesignSystemColor.Foreground.subtle,
                        style: StrokeStyle(lineWidth: 3, dash: [3.5])
                    )
                    .frame(width: 20, height: 20)
            }
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
                    .foregroundStyle(DesignSystemColor.Accent.selectedBlue)
                    .padding(.vertical, 9)
                    .padding(.horizontal, 18)
                    .frame(minHeight: 44)
                    .overlay {
                        Capsule().strokeBorder(DesignSystemColor.Accent.selectedBlue, lineWidth: 1)
                    }
            }
        }
        .padding(.top, 30)
        .frame(maxWidth: .infinity)
    }
}
