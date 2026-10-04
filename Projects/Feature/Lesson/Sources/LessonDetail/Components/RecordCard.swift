import SwiftUI

import DesignSystem
import DomainInterface

struct RecordCard: View {
    let record: LearningHistory?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("학습 기록")
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)

            RecordCell(label: "학습 횟수", value: record.map { "\($0.studyCount)회" } ?? "-")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(DesignSystemAsset.bgMuted.swiftUIColor)
        .clipShape(.rect(cornerRadius: 12))
    }
}

private struct RecordCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            Text(value)
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
        }
    }
}
