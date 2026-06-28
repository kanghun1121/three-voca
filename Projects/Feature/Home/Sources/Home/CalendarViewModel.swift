import Foundation

import DomainInterface

@Observable
final class CalendarViewModel {
    private(set) var monthOffset: Int = 0
    let today: Date

    init(today: Date = Calendar.current.startOfDay(for: .now)) {
        self.today = today
    }

    private var cal: Calendar { .current }

    var displayedDate: Date {
        cal.date(byAdding: .month, value: monthOffset, to: today) ?? today
    }

    var year: Int { cal.component(.year, from: displayedDate) }
    var month: Int { cal.component(.month, from: displayedDate) }
    var isAtCurrentMonth: Bool { monthOffset == 0 }

    var rows: [[Int?]] {
        let count = cal.range(of: .day, in: .month, for: displayedDate)?.count ?? 30
        var comps = cal.dateComponents([.year, .month], from: displayedDate)
        comps.day = 1
        let firstDow = cal.date(from: comps).map { cal.component(.weekday, from: $0) - 1 } ?? 0
        let cells: [Int?] = Array(repeating: nil, count: firstDow) + (1...count).map { Optional($0) }
        return stride(from: 0, to: cells.count, by: 7).map { start in
            let end = min(start + 7, cells.count)
            let row = Array(cells[start..<end])
            return row + Array(repeating: nil, count: 7 - row.count)
        }
    }

    func previousMonth() { monthOffset -= 1 }

    func nextMonth() {
        guard !isAtCurrentMonth else { return }
        monthOffset += 1
    }

    func goToToday() { monthOffset = 0 }
}
