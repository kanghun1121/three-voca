import SwiftUI

struct SessionRow: View {
    let presentationModel: SessionRowPresentationModel

    private var title: String { "Session \(presentationModel.sessionNumber)" }
    private var subtitle: String {
        if let pct = presentationModel.accuracyPercent {
            return "완료 · \(pct)%"
        }
        return "시작 전"
    }

    var body: some View {
        HStack(spacing: 12) {
            SessionStatusIcon(kind: presentationModel.icon)
            SessionInfo(title: title, subtitle: subtitle)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SessionRow(presentationModel: SessionRowPresentationModel(
            id: 1,
            sessionNumber: 1,
            accuracyPercent: 92,
            icon: .completedHigh
        ))
        SessionRow(presentationModel: SessionRowPresentationModel(
            id: 2,
            sessionNumber: 3,
            accuracyPercent: 58,
            icon: .completedLow
        ))
        SessionRow(presentationModel: SessionRowPresentationModel(
            id: 3,
            sessionNumber: 5,
            accuracyPercent: nil,
            icon: .notStarted
        ))
        SessionRow(presentationModel: SessionRowPresentationModel(
            id: 4,
            sessionNumber: 6,
            accuracyPercent: nil,
            icon: .notStarted
        ))
    }
    .padding()
}
