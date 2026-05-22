import SwiftUI

struct RecordCard: View {
    let record: SessionDetailViewState.Record?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("학습 기록")
                .font(.subheadline)
                .fontWeight(.semibold)

            if let record {
                RecordGrid(record: record)
            } else {
                EmptyRecordPlaceholder()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(.rect(cornerRadius: 12))
    }
}

private struct RecordGrid: View {
    let record: SessionDetailViewState.Record

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            alignment: .leading,
            spacing: 16
        ) {
            RecordCell(label: "처음 완료", value: record.firstCompletedDateText)
            RecordCell(label: "마지막 학습", value: record.lastStudiedRelativeText)
            RecordCell(label: "복습 횟수", value: record.reviewCountText)
            RecordCell(label: "평균 정답률", value: record.averageAccuracyText)
        }
    }
}

private struct EmptyRecordPlaceholder: View {
    var body: some View {
        Text("아직 학습 기록이 없습니다.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
    }
}

private struct RecordCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}
