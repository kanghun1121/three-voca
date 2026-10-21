import SwiftUI

import DesignSystem
import DomainInterface

struct RecordCard: View {
    let record: LearningHistory?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("학습 기록")
                .typography(DesignSystemTypography.Pretendard.bold14)
                .foregroundStyle(DesignSystemColor.Foreground.muted)

            RecordCell(label: "학습 횟수", value: record.map { "\($0.studyCount)회" } ?? "-")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(DesignSystemColor.Background.muted)
        .clipShape(.rect(cornerRadius: 12))
    }
}

private struct RecordCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .typography(DesignSystemTypography.Pretendard.semiBold12)
                .foregroundStyle(DesignSystemColor.Foreground.muted)
            Text(value)
                .typography(DesignSystemTypography.Pretendard.bold16)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
        }
    }
}
