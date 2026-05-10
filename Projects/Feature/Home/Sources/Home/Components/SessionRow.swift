import SwiftUI

struct SessionRow: View {
    let viewState: SessionRowViewState

    var body: some View {
        HStack(spacing: 10) {
            SessionStatusIcon(kind: viewState.icon)
            Text(viewState.title)
                .font(.subheadline)
            Spacer()
            Text(viewState.trailingText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SessionRow(viewState: SessionRowViewState(
            id: "1",
            title: "Session 1",
            trailingText: "완료 · 92%",
            icon: .completedHigh
        ))
        SessionRow(viewState: SessionRowViewState(
            id: "2",
            title: "Session 3",
            trailingText: "완료 · 58%",
            icon: .completedLow
        ))
        SessionRow(viewState: SessionRowViewState(
            id: "3",
            title: "Session 5",
            trailingText: "시작 전",
            icon: .notStarted
        ))
        SessionRow(viewState: SessionRowViewState(
            id: "4",
            title: "Session 6",
            trailingText: "시작 전",
            icon: .notStarted
        ))
    }
    .padding()
}
