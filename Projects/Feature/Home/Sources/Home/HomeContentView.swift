import SwiftUI

import DesignSystem
import UseCaseInterface

struct HomeContentView: View {
    let state: HomePresentationModel
    let viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeGreetingHeader()
                MonthlyCalendarCard(viewModel: viewModel)
                .padding(.horizontal, 18)
                .padding(.bottom, 22)
                HomeLevelList(
                    levels: state.levels,
                    expandedLevelIDs: viewModel.expandedLevelIDs,
                    onLevelTapped: { viewModel.levelTapped(id: $0) },
                    onSessionTapped: { viewModel.sessionTapped(id: $0) }
                )
            }
        }
        .background(DesignSystemAsset.bg.swiftUIColor)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    HomeContentView(state: VocabularyLibrary.previewFixture.toHomePresentationModel(), viewModel: HomeViewModel())
}
