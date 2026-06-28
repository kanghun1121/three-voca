import SwiftUI

import DesignSystem

struct LevelCard: View {
    let presentationModel: LevelCardPresentationModel
    let isExpanded: Bool
    let action: () -> Void
    let onSessionTapped: (Int) -> Void

    private var levelColor: Color { HomeColors.levelColor(presentationModel.level) }
    private var isActive: Bool { presentationModel.status == .active }

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
                status: presentationModel.status,
                levelColor: levelColor
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
        .background(cardBackground)
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isActive ? HomeColors.activeBorder : DesignSystemAsset.borderSubtle.swiftUIColor,
                    lineWidth: 1
                )
        }
        .shadow(
            color: isActive
                ? DesignSystemAsset.primary.swiftUIColor.opacity(0.10)
                : Color.clear,
            radius: 12,
            x: 0,
            y: 4
        )
        .animation(.easeOut(duration: 0.2), value: isExpanded)
    }

    @ViewBuilder
    private var cardBackground: some View {
        if isActive {
            LinearGradient(
                colors: [
                    Color(red: 245/255, green: 249/255, blue: 255/255),
                    Color.white
                ],
                startPoint: UnitPoint(x: 0.2, y: 0.0),
                endPoint: UnitPoint(x: 1.0, y: 1.0)
            )
        } else {
            DesignSystemAsset.white.swiftUIColor
        }
    }
}
