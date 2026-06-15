import SwiftUI

import DesignSystem
import DomainInterface

struct HeatmapCard: View {
    let activities: [DailyActivity]

    private let totalWeeks = 18

    private var activityMap: [String: Int] {
        Dictionary(uniqueKeysWithValues: activities.map { ($0.date, $0.sessionsCount) })
    }

    // columns = weeks (oldest first), rows = weekday (0=Sun … 6=Sat)
    private var grid: [[Date?]] {
        let cal = Calendar.current
        let todayWeekday = cal.component(.weekday, from: Date.now) - 1
        guard
            let latestSunday = cal.date(byAdding: .day, value: -todayWeekday, to: Date.now),
            let firstSunday = cal.date(byAdding: .weekOfYear, value: -(totalWeeks - 1), to: latestSunday)
        else { return [] }

        return (0..<totalWeeks).map { week -> [Date?] in
            guard let weekStart = cal.date(byAdding: .weekOfYear, value: week, to: firstSunday) else {
                return [Date?](repeating: nil, count: 7)
            }
            return (0..<7).map { day in
                guard let date = cal.date(byAdding: .day, value: day, to: weekStart) else { return nil }
                return date <= Date.now ? date : nil
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("학습 기록")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 15.5))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            HeatmapGridSection(grid: grid, activityMap: activityMap)
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
}

#Preview {
    HeatmapCard(activities: DailyActivity.previewFixture)
        .padding()
}
