import SwiftUI

import DesignSystem

struct RecordCard: View {
    let record: SessionDetailPresentationModel.Record?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("학습 기록")
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)

            HStack(spacing: 0) {
                RecordCell(
                    label: "처음 완료",
                    value: record?.firstCompletedDateText ?? "-"
                )
                Divider()
                    .frame(height: 36)
                    .padding(.horizontal, 16)
                RecordCell(
                    label: "복습 횟수",
                    value: record.map { "\($0.reviewCount)회" } ?? "-"
                )
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
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
