import SwiftUI

import DesignSystem
import FeatureHome
import FeatureMyPage

import Dependencies

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView(viewModel: withDependencies {
                $0.getHomeOverviewUseCase = .liveValue
                $0.getHeatmapDataUseCase = .liveValue
                $0.getSessionDetailUseCase = .liveValue
                $0.completeSessionUseCase = .liveValue
                $0.getWordDetailUseCase = .liveValue
                $0.prefetchWordDetailsUseCase = .liveValue
                $0.prefetchAudioUseCase = .liveValue
                $0.getAudioURLUseCase = .liveValue
                $0.playAudioUseCase = .liveValue
                $0.stopAudioUseCase = .liveValue
            } operation: {
                HomeViewModel()
            })
            .tabItem {
                Label("홈", systemImage: "house.fill")
            }

            MyPageView(viewModel: withDependencies {
                $0.logoutUseCase = .liveValue
                $0.deleteAccountUseCase = .liveValue
            } operation: {
                MyPageViewModel()
            })
            .tabItem {
                Label("마이페이지", systemImage: "person.fill")
            }
        }
        .tint(DesignSystemAsset.growDeep.swiftUIColor)
    }
}
