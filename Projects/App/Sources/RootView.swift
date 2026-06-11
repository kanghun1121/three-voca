import SwiftUI

import Domain
import DomainInterface
import FeatureHome
import FeatureLogin

import Dependencies

struct RootView: View {
    @State private var viewModel = AppViewModel()

    var body: some View {
        Group {
            switch viewModel.authState {
            case .checking:
                ProgressView()
            case .unauthenticated:
                LoginView(viewModel: withDependencies {
                    $0.authClient = .liveValue
                } operation: {
                    LoginViewModel()
                })
            case .authenticated:
                HomeView(viewModel: withDependencies {
                    $0.homeClient = .liveValue
                    $0.sessionClient = .liveValue
                    $0.wordClient = .liveValue
                    $0.audioClient = .liveValue
                    $0.audioPlayerClient = .liveValue
                } operation: {
                    HomeViewModel()
                })
            }
        }
        .task { viewModel.onAppear() }
    }
}
