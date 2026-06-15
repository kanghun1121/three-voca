import SwiftUI

struct HeatmapGridRow: View {
    let grid: [[Date?]]
    let activityMap: [String: Int]

    @ScaledMetric private var cellGap: CGFloat = 3

    var body: some View {
        HStack(spacing: cellGap) {
            HeatmapDayGutter()
            ForEach(0..<grid.count, id: \.self) { week in
                HeatmapWeekColumn(days: grid[week], activityMap: activityMap)
            }
            Spacer(minLength: 0)
        }
    }
}
