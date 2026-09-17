import SwiftUI

import DesignSystem

/// 26×26 원형 세션 인덱스 배지. 완료=단계색 채움+체크, 진행중=단계색 아웃라인, 이후=회색 채움.
struct SessionIndexBadge: View {
    let sessionNumber: Int
    let status: SessionStatus
    let level: Int

    var body: some View {
        ZStack {
            switch status {
            case .completed:
                Circle().fill(StageColor.resolveDark(forLevel: level))
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                    .accessibilityHidden(true)
            case .active:
                Circle().stroke(StageColor.resolveDark(forLevel: level), lineWidth: 2)
                numberLabel(color: StageColor.resolveDark(forLevel: level))
            case .upcoming:
                Circle().fill(DesignSystemAsset.badgeIdleBg.swiftUIColor)
                numberLabel(color: DesignSystemAsset.textCaption.swiftUIColor)
            }
        }
        .frame(width: 26, height: 26)
    }

    private func numberLabel(color: Color) -> some View {
        Text("\(sessionNumber)")
            .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
            .monospacedDigit()
            .foregroundStyle(color)
    }
}
