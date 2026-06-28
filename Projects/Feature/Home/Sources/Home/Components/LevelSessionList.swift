import SwiftUI

import DesignSystem

struct LevelSessionList: View {
    let sessions: [SessionRowPresentationModel]
    let onSessionTapped: (Int) -> Void

    @State private var showAll = false

    private let maxVisibleSessions = 6

    private var visibleSessions: [SessionRowPresentationModel] {
        showAll ? sessions : Array(sessions.prefix(maxVisibleSessions))
    }

    private var hasOverflow: Bool {
        !showAll && sessions.count > maxVisibleSessions
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(visibleSessions) { session in
                Button {
                    onSessionTapped(session.id)
                } label: {
                    SessionRow(presentationModel: session)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 9)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
            }
            if hasOverflow {
                Button {
                    showAll = true
                } label: {
                    Text("+ 모두 보기")
                        .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                        .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
