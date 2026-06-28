import SwiftUI

import DesignSystem
import DomainInterface

struct MonthlyCalendarCard: View {
    let activities: [DailyActivity]
    let streakDays: Int

    @State private var monthOffset: Int = 0

    private let cal = Calendar.current
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private var today: Date { cal.startOfDay(for: Date.now) }

    private var displayedDate: Date {
        cal.date(byAdding: .month, value: monthOffset, to: today) ?? today
    }

    private var year: Int { cal.component(.year, from: displayedDate) }
    private var month: Int { cal.component(.month, from: displayedDate) }

    private var daysInMonth: Int {
        cal.range(of: .day, in: .month, for: displayedDate)?.count ?? 30
    }

    private var firstDow: Int {
        var comps = cal.dateComponents([.year, .month], from: displayedDate)
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
                .padding(.bottom, 19)
            CalendarWeekdayHeader()
                .padding(.bottom, 6)
            gridSection
            footerRow
                .padding(.top, 17)
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

    private var isAtCurrentMonth: Bool { monthOffset == 0 }

    private var headerRow: some View {
        HStack(spacing: 8) {
            Text("\(String(year))년 \(String(month))월")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 15.5))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            Spacer()
            HStack(spacing: 2) {
                Button {
                    monthOffset -= 1
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                        .frame(width: 28, height: 28)
                }
                Button {
                    guard !isAtCurrentMonth else { return }
                    monthOffset += 1
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(
                            isAtCurrentMonth
                                ? DesignSystemAsset.fgMuted.swiftUIColor
                                : DesignSystemAsset.fgStrong.swiftUIColor
                        )
                        .frame(width: 28, height: 28)
                }
            }
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
        var comps = cal.dateComponents([.year, .month], from: displayedDate)
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
            if streakDays > 0 && monthOffset == 0 {
                HStack(spacing: 5) {
                    DesignSystemAsset.flame.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                    Text("\(streakDays)일 연속")
                        .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
                        .foregroundStyle(HomeColors.streakOrange)
                }
            }
            Spacer()
            if monthOffset != 0 {
                Button {
                    monthOffset = 0
                } label: {
                    Text("오늘로")
                        .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                        .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(DesignSystemAsset.primary.swiftUIColor.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 8))
                }
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
