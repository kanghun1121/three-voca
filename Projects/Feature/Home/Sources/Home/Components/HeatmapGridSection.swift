import SwiftUI

struct HeatmapGridSection: View {
    let grid: [[Date?]]
    let activityMap: [String: Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HeatmapMonthLabelRow(grid: grid)
            HeatmapGridRow(grid: grid, activityMap: activityMap)
        }
    }
}
