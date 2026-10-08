import SwiftUI

import DesignSystem

struct SelectedDateContextRow: View {
    let date: Date
    let isToday: Bool
    let recordCount: Int

    private var dateLabel: String {
        let base = date.formatted(.dateTime.month().day().locale(Locale(identifier: "ko_KR")))
        return isToday ? "\(base) · 오늘" : base
    }

    private var countLabel: String {
        recordCount == 0 ? "기록 없음" : "레슨 \(recordCount)개"
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(dateLabel)
                .typography(DesignSystemTypography.Home.selectedDateContext)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
            Spacer()
            Text(countLabel)
                .typography(DesignSystemTypography.Home.lessonCountCaption)
                .foregroundStyle(DesignSystemColor.Foreground.subtle)
        }
        .padding(.top, 22)
        .padding(.horizontal, 24)
    }
}
