import SwiftUI

import DesignSystem

struct HomeLevelList: View {
    let levels: [LevelCardPresentationModel]
    let expandedLevelID: String?
    let onLevelTapped: (String) -> Void
    let onSessionTapped: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("전체 단계")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
                .padding(.horizontal, 18)
            LazyVStack(spacing: 9) {
                ForEach(levels) { level in
                    LevelCard(
                        presentationModel: level,
                        isExpanded: expandedLevelID == level.id
                    ) {
                        onLevelTapped(level.id)
                    } onSessionTapped: { id in
                        onSessionTapped(id)
                    }
                }
            }
            .padding(.horizontal, 18)
        }
        .padding(.bottom, 24)
    }
}
