import SwiftUI

import DomainInterface
import DesignSystem
import Dependencies

struct HomeContentView: View {
    let state: HomePresentationModel
    let heatmapData: [DailyActivity]
    let expandedLevelID: String?
    let onLevelTapped: (String) -> Void
    let onSessionTapped: (Int) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                greetingHeader
                HeatmapCard(activities: heatmapData)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 22)
                sectionLabel
                stageList
            }
        }
        .background(DesignSystemAsset.bg.swiftUIColor)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("오늘도 가볍게")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            Text("3초 안에 떠올려볼까요?")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 25))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .tracking(-0.55)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
        .padding(.horizontal, 22)
        .padding(.bottom, 18)
    }

    private var sectionLabel: some View {
        Text("전체 단계")
            .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12.5))
            .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.bottom, 8)
    }

    private var stageList: some View {
        LazyVStack(spacing: 9) {
            ForEach(state.levels) { level in
                LevelCard(
                    presentationModel: level,
                    isExpanded: expandedLevelID == level.id,
                    action: { onLevelTapped(level.id) },
                    onSessionTapped: onSessionTapped
                )
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 24)
    }
}

#Preview {
    HomeContentView(
        state: VocabularyLibrary.previewFixture.toHomePresentationModel(),
        heatmapData: DailyActivity.previewFixture,
        expandedLevelID: nil,
        onLevelTapped: { _ in },
        onSessionTapped: { _ in }
    )
}
