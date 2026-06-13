import SwiftUI

import DomainInterface
import DesignSystem

struct HeatmapCard: View {
    let activities: [DailyActivity]

    private let totalWeeks = 18
    private let cellSize: CGFloat = 13
    private let cellGap: CGFloat = 3
    private let dayGutterWidth: CGFloat = 12

    private var activityMap: [String: Int] {
        Dictionary(uniqueKeysWithValues: activities.map { ($0.date, $0.sessionsCount) })
    }

    // columns = weeks (oldest first), rows = weekday (0=Sun … 6=Sat)
    private var grid: [[Date?]] {
        let cal = Calendar.current
        let todayWeekday = cal.component(.weekday, from: Date.now) - 1 // 0-indexed Sun
        let latestSunday = cal.date(byAdding: .day, value: -todayWeekday, to: Date.now)!
        let firstSunday = cal.date(byAdding: .weekOfYear, value: -(totalWeeks - 1), to: latestSunday)!
        return (0..<totalWeeks).map { week in
            let weekStart = cal.date(byAdding: .weekOfYear, value: week, to: firstSunday)!
            return (0..<7).map { day in
                let date = cal.date(byAdding: .day, value: day, to: weekStart)!
                return date <= Date.now ? date : nil
            }
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private func level(for date: Date?) -> Int {
        guard let date else { return -1 }
        let key = Self.dateFormatter.string(from: date)
        switch activityMap[key] ?? 0 {
        case 0: return 0
        case 1: return 1
        case 2: return 2
        case 3: return 3
        default: return 4
        }
    }

    private func cellColor(level: Int) -> Color {
        switch level {
        case -1: return .clear
        case 0: return DesignSystemAsset.heatmap0.swiftUIColor
        case 1: return DesignSystemAsset.heatmap1.swiftUIColor
        case 2: return DesignSystemAsset.heatmap2.swiftUIColor
        case 3: return DesignSystemAsset.heatmap3.swiftUIColor
        default: return DesignSystemAsset.primary.swiftUIColor
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("학습 기록")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 15.5))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            VStack(alignment: .leading, spacing: 4) {
                monthLabelRow
                gridRow
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private var monthLabelRow: some View {
        HStack(spacing: cellGap) {
            Spacer().frame(width: dayGutterWidth)
            ForEach(0..<grid.count, id: \.self) { week in
                Text(monthLabel(for: week) ?? "")
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 8.5))
                    .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
                    .frame(width: cellSize, alignment: .leading)
            }
        }
        .frame(height: 15)
    }

    private var gridRow: some View {
        HStack(spacing: cellGap) {
            dayGutter
            ForEach(0..<grid.count, id: \.self) { week in
                VStack(spacing: cellGap) {
                    ForEach(0..<7, id: \.self) { day in
                        let lvl = level(for: grid[week][day])
                        RoundedRectangle(cornerRadius: 3)
                            .fill(cellColor(level: lvl))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var dayGutter: some View {
        let labels = ["", "월", "", "수", "", "금", ""]
        return VStack(alignment: .leading, spacing: cellGap) {
            ForEach(0..<7, id: \.self) { row in
                Text(labels[row])
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 8.5))
                    .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
                    .frame(width: dayGutterWidth, height: cellSize, alignment: .leading)
            }
        }
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

#Preview {
    HeatmapCard(activities: DailyActivity.previewFixture)
        .padding()
}
