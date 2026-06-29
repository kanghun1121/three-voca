import SwiftUI

import DesignSystem

struct CalendarWeekdayHeader: View {
    private let labels = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(labels.indices, id: \.self) { index in
                Text(labels[index])
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 11))
                    .foregroundStyle(foregroundColor(index: index))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func foregroundColor(index: Int) -> Color {
        if index == 0 { return DesignSystemAsset.sundayRed.swiftUIColor }
        if index == 6 { return DesignSystemAsset.saturdayBlue.swiftUIColor }
        return DesignSystemAsset.fgMuted.swiftUIColor
    }
}
