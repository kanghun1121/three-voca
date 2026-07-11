import SwiftUI

import DesignSystem

struct SessionCell: View {
    let sessionNumber: Int
    let status: SessionCellStatus

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(backgroundColor)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if status == .current {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(DesignSystemAsset.progressActive.swiftUIColor, lineWidth: 2)
                }
            }
            .overlay { icon }
            .shadow(
                color: status == .current
                    ? DesignSystemAsset.progressActive.swiftUIColor.opacity(0.18)
                    : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
    }

    private var backgroundColor: Color {
        switch status {
        case .done: DesignSystemAsset.progressActive.swiftUIColor
        case .current: DesignSystemAsset.white.swiftUIColor
        case .todo: DesignSystemAsset.lockBg.swiftUIColor
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch status {
        case .done:
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                .accessibilityHidden(true)
        case .current:
            EmptyView()
        case .todo:
            Text("\(sessionNumber)")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
                .foregroundStyle(DesignSystemAsset.lock.swiftUIColor)
                .monospacedDigit()
        }
    }
}
