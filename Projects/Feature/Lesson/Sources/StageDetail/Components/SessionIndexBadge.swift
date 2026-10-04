import SwiftUI

import DesignSystem

/// 26×26 원형 세션 인덱스 배지. 완료=단계색 채움+체크, 미완료=회색 채움.
struct SessionIndexBadge: View {
    let sessionNumber: Int
    let isCompleted: Bool
    let level: Int

    var body: some View {
        ZStack {
            if isCompleted {
                Circle().fill(StageColor.resolveDark(forLevel: level))
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                    .accessibilityHidden(true)
            } else {
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
