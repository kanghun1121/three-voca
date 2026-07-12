import SwiftUI

struct SessionGrid: View {
    let sessions: [SessionRowPresentationModel]
    let onSessionTapped: (Int) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 6)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 7) {
            ForEach(sessions) { session in
                Button {
                    onSessionTapped(session.id)
                } label: {
                    SessionCell(sessionNumber: session.sessionNumber, status: session.status)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(makeAccessibilityLabel(for: session))
            }
        }
    }

    private func makeAccessibilityLabel(for session: SessionRowPresentationModel) -> String {
        switch session.status {
        case .done: "\(session.sessionNumber)번 세션, 완료"
        case .current: "\(session.sessionNumber)번 세션, 진행 중"
        case .todo: "\(session.sessionNumber)번 세션, 잠김"
        }
    }
}
