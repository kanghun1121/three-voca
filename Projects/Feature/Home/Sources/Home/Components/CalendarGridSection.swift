import SwiftUI

import DesignSystem

struct CalendarGridSection: View {
    let rows: [[Int?]]
    let activityMap: [String: CalendarDayIntensity]
    let today: Date
    let displayedDate: Date

    private let cal = Calendar.current
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var body: some View {
        VStack(spacing: 4) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    ForEach(rows[rowIndex].indices, id: \.self) { colIndex in
                        cellView(day: rows[rowIndex][colIndex])
                    }
                }
            }
        }
    }

    private func cellView(day: Int?) -> some View {
        guard let day else {
            return CalendarDayCell(kind: .empty)
        }
        var comps = cal.dateComponents([.year, .month], from: displayedDate)
        comps.day = day
        guard let date = cal.date(from: comps) else {
            return CalendarDayCell(kind: .notStudied(day))
        }
        let dayStart = cal.startOfDay(for: date)
        let isToday = dayStart == today
        let isFuture = dayStart > today
        let dateKey = Self.dateFormatter.string(from: date)
        let intensity = activityMap[dateKey]

        if isToday {
            return CalendarDayCell(kind: .today(day, intensity))
        } else if isFuture {
            return CalendarDayCell(kind: .future(day))
        } else if let intensity {
            return CalendarDayCell(kind: .studied(day, intensity))
        } else {
            return CalendarDayCell(kind: .notStudied(day))
        }
    }
}
