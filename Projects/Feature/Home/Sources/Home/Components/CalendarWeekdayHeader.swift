import SwiftUI

import DesignSystem

struct CalendarWeekdayHeader: View {
    private let labels = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                Text(label)
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 11))
                    .foregroundStyle(foregroundColor(index: index))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func foregroundColor(index: Int) -> Color {
        if index == 0 { return Color(red: 229/255, green: 72/255, blue: 77/255) }  // 일 #E5484D
        if index == 6 { return Color(red: 58/255, green: 111/255, blue: 247/255) } // 토 #3A6FF7
        return DesignSystemAsset.fgMuted.swiftUIColor
    }
}
