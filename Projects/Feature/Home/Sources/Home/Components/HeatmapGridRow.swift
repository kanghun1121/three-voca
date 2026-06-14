import SwiftUI

import DesignSystem

struct HeatmapGridRow: View {
    let grid: [[Date?]]
    let activityMap: [String: Int]

    @ScaledMetric private var cellSize: CGFloat = 15
    @ScaledMetric private var cellGap: CGFloat = 3

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var body: some View {
        HStack(spacing: cellGap) {
            HeatmapDayGutter()
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
}
