import SwiftUI

import DesignSystem

struct LevelCard: View {
    let presentationModel: LevelCardPresentationModel
    let isExpanded: Bool
    let action: () -> Void
    let onSessionTapped: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                LevelCardHeader(
                    level: presentationModel.level,
                    name: presentationModel.name,
                    status: presentationModel.status,
                    completedSessions: presentationModel.completedSessions,
                    totalSessions: presentationModel.totalSessions,
                    isExpanded: isExpanded
                )
            }
            .buttonStyle(.plain)
            LevelProgressBar(
                progressRatio: presentationModel.progressRatio,
                status: presentationModel.status
            )
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)
                LevelSessionList(
                    sessions: presentationModel.sessions,
                    onSessionTapped: onSessionTapped
                )
            }
        }
        .background(DesignSystemAsset.white.swiftUIColor)
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    presentationModel.status == .active
                        ? DesignSystemAsset.primary.swiftUIColor.opacity(0.18)
                        : DesignSystemAsset.borderSubtle.swiftUIColor,
                    lineWidth: 1
                )
        }
        .animation(.easeOut(duration: 0.2), value: isExpanded)
    }
}
