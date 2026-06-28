import SwiftUI

import DesignSystem
import DomainInterface

struct MonthlyCalendarCard: View {
    let activities: [DailyActivity]
    let streakDays: Int

    private let cal = Calendar.current
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    private var today: Date { cal.startOfDay(for: Date.now) }

    private var year: Int { cal.component(.year, from: today) }
    private var month: Int { cal.component(.month, from: today) }

    private var daysInMonth: Int {
        cal.range(of: .day, in: .month, for: today)?.count ?? 30
    }

    // 해당 월 1일의 요일 오프셋 (0=일, 6=토)
    private var firstDow: Int {
        var comps = cal.dateComponents([.year, .month], from: today)
        comps.day = 1
        guard let firstDay = cal.date(from: comps) else { return 0 }
        return cal.component(.weekday, from: firstDay) - 1
    }

    private var activityMap: [String: CalendarDayIntensity] {
        Dictionary(uniqueKeysWithValues: activities.compactMap { activity -> (String, CalendarDayIntensity)? in
            let intensity: CalendarDayIntensity
            switch activity.sessionsCount {
            case 1:    intensity = .light
            case 2:    intensity = .mid
            default:   intensity = .full
            }
            return (activity.date, intensity)
        })
    }

    private var studiedThisMonth: Int {
        let prefix = String(format: "%04d-%02d", year, month)
        return activityMap.keys.filter { $0.hasPrefix(prefix) }.count
    }

    // 셀 배열: nil=빈칸, Int=날짜
    private var cells: [Int?] {
        Array(repeating: nil, count: firstDow) + (1...daysInMonth).map { Optional($0) }
    }

    private var rows: [[Int?]] {
        stride(from: 0, to: cells.count, by: 7).map { start in
            let end = min(start + 7, cells.count)
            let row = Array(cells[start..<end])
            return row + Array(repeating: nil, count: 7 - row.count)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
                .padding(.bottom, 14)
            CalendarWeekdayHeader()
                .padding(.bottom, 6)
            gridSection
            footerRow
                .padding(.top, 12)
        }
        .padding(.horizontal, 16)
        .padding(.top, 17)
        .padding(.bottom, 15)
        .background(DesignSystemAsset.white.swiftUIColor)
        .clipShape(.rect(cornerRadius: 20))
        .shadow(
            color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.06),
            radius: 20,
            x: 0,
            y: 6
        )
    }

    private var headerRow: some View {
        HStack {
            Text("\(year)년 \(month)월")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 15.5))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            Spacer()
            Text("이번 달 \(studiedThisMonth)일 학습")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
        }
    }

    private var gridSection: some View {
        VStack(spacing: 4) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, day in
                        cellView(day: day)
                    }
                }
            }
        }
    }

    private func cellView(day: Int?) -> some View {
        guard let day else {
            return CalendarDayCell(kind: .empty)
        }
        var comps = cal.dateComponents([.year, .month], from: today)
        comps.day = day
        guard let date = cal.date(from: comps) else {
            return CalendarDayCell(kind: .notStudied(day))
        }
        let dayStart = cal.startOfDay(for: date)
        let isToday = dayStart == today
        let isFuture = dayStart > today
        let dateKey = dateFormatter.string(from: date)
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

    private var footerRow: some View {
        HStack(spacing: 0) {
            if streakDays > 0 {
                HStack(spacing: 5) {
                    Text("🔥")
                        .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
                    Text("\(streakDays)일 연속")
                        .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
                        .foregroundStyle(HomeColors.streakOrange)
                }
            }
            Spacer()
            if studiedThisMonth > 0 {
                Text("오늘도 학습을 마쳤어요")
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            }
        }
    }
}

#Preview {
    MonthlyCalendarCard(
        activities: DailyActivity.previewFixture,
        streakDays: 5
    )
    .padding()
}
