import SwiftUI

import DesignSystem

struct CalendarWeekdayHeader: View {
    private let labels = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(labels.indices, id: \.self) { index in
                Text(labels[index])
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 11))
                    .foregroundStyle(foregroundColor(index: index))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func foregroundColor(index: Int) -> Color {
        index == labels.count - 1
            ? DesignSystemAsset.positive.swiftUIColor
            : DesignSystemAsset.fgSubtle.swiftUIColor
    }
}
