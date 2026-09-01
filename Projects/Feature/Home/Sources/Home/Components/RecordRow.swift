import SwiftUI

import DesignSystem

struct RecordRow: View {
    let record: DayRecord
    let onTapped: () -> Void

    private var timeLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: record.time)
    }

    var body: some View {
        Button(action: onTapped) {
            HStack(spacing: 14) {
                Text(timeLabel)
                    .homeTypography(.recordRowMeta)
                    .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
                    .monospacedDigit()
                    .frame(width: 46, alignment: .leading)
                Circle()
                    .fill(DesignSystemAsset.study300.swiftUIColor)
                    .frame(width: 7, height: 7)
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.title)
                        .homeTypography(.recordRowTitle)
                        .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                    Text("\(record.wordCount)단어")
                        .homeTypography(.recordRowMeta)
                        .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
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
