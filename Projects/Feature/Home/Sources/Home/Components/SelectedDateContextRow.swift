import SwiftUI

import DesignSystem

struct SelectedDateContextRow: View {
    let date: Date
    let isToday: Bool
    let recordCount: Int

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        let base = formatter.string(from: date)
        return isToday ? "\(base) · 오늘" : base
    }

    private var countLabel: String {
        recordCount == 0 ? "기록 없음" : "세션 \(recordCount)개"
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(dateLabel)
                .homeTypography(.selectedDateContext)
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            Spacer()
            Text(countLabel)
                .homeTypography(.sessionCountCaption)
                .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
        }
        .padding(.top, 22)
        .padding(.horizontal, 24)
    }
}
