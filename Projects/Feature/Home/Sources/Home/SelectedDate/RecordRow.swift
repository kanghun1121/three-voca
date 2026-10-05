import SwiftUI

import DesignSystem

struct RecordRow: View {
    let record: DayRecord
    let onTapped: () -> Void

    var body: some View {
        Button(action: onTapped) {
            HStack(spacing: 14) {
                Text(
                    record.time,
                    format: .dateTime
                        .hour(.twoDigits(amPM: .omitted))
                        .minute(.twoDigits)
                        .locale(Locale(identifier: "ko_KR"))
                )
                .typography(DesignSystemTypography.Home.recordTime)
                .foregroundStyle(DesignSystemColor.Foreground.subtle)
                .frame(width: 46, alignment: .leading)
                Circle()
                    .fill(DesignSystemColor.Accent.recordDotPurple)
                    .frame(width: 7, height: 7)
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.title)
                        .typography(DesignSystemTypography.Home.recordRowTitle)
                        .foregroundStyle(DesignSystemColor.Foreground.strong)
                    Text("\(record.wordCount)단어")
                        .typography(DesignSystemTypography.Home.recordRowMeta)
                        .foregroundStyle(DesignSystemColor.Foreground.subtle)
                }
                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
