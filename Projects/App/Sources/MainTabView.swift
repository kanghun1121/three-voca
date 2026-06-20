import SwiftUI

import DesignSystem
import FeatureHome
import FeatureMyPage

import Dependencies

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView(viewModel: withDependencies {
                $0.homeClient = .liveValue
                $0.sessionClient = .liveValue
                $0.wordClient = .liveValue
                $0.audioClient = .liveValue
                $0.audioPlayerClient = .liveValue
            } operation: {
                HomeViewModel()
            })
            .tabItem {
                Label("홈", systemImage: "house.fill")
            }

            MyPageView(viewModel: withDependencies {
                $0.authSessionClient = .liveValue
            } operation: {
                MyPageViewModel()
            })
            .tabItem {
                Label("마이페이지", systemImage: "person.fill")
            }
        }
        .tint(DesignSystemAsset.primary.swiftUIColor)
    }
}
