import SwiftUI

import DesignSystem

struct HeatmapMonthLabelRow: View {
    let grid: [[Date?]]

    @ScaledMetric private var cellSize: CGFloat = 15
    @ScaledMetric private var cellGap: CGFloat = 3
    @ScaledMetric private var dayGutterWidth: CGFloat = 12
    @ScaledMetric private var rowHeight: CGFloat = 15

    var body: some View {
        HStack(spacing: cellGap) {
            Spacer().frame(width: dayGutterWidth)
            ForEach(0..<grid.count, id: \.self) { week in
                Text(monthLabel(for: week) ?? "")
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 8.5))
                    .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
                    .frame(width: cellSize, alignment: .leading)
            }
        }
        .frame(height: rowHeight)
    }

    private func monthLabel(for weekIndex: Int) -> String? {
        let cal = Calendar.current
        let datesInWeek = grid[weekIndex].compactMap { $0 }
        guard let first = datesInWeek.first else { return nil }
        let currMonth = cal.component(.month, from: first)
        if weekIndex == 0 { return monthAbbrev(currMonth) }
        let prevDates = grid[weekIndex - 1].compactMap { $0 }
        let prevMonth = prevDates.first.map { cal.component(.month, from: $0) }
        return prevMonth != currMonth ? monthAbbrev(currMonth) : nil
    }

    private func monthAbbrev(_ month: Int) -> String {
        "\(month)월"
    }
}
