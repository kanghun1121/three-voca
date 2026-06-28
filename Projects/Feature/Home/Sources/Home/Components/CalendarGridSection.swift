import SwiftUI

struct CalendarGridSection: View {
    let rows: [[Int?]]
    let activityMap: [String: CalendarDayIntensity]
    let today: Date
    let displayedDate: Date

    var body: some View {
        VStack(spacing: 4) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                CalendarWeekRow(
                    days: rows[rowIndex],
                    activityMap: activityMap,
                    today: today,
                    displayedDate: displayedDate
                )
            }
        }
    }
}
