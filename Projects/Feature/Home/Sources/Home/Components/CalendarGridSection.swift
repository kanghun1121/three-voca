import SwiftUI

struct CalendarGridSection: View {
    let rows: [[CalendarDay]]
    let activityMap: [String: CalendarDayIntensity]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                CalendarWeekRow(days: rows[rowIndex], activityMap: activityMap)
            }
        }
    }
}
