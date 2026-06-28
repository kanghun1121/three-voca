import SwiftUI

import Domain
import DomainInterface
import FeatureLogin

import Dependencies

struct RootView: View {
    @State private var viewModel = AppViewModel()

    var body: some View {
        Group {
            if viewModel.isCheckingSession {
                SplashView()
                    .transition(.opacity)
            } else {
                switch viewModel.authState {
                case .unauthenticated:
                    LoginView(viewModel: withDependencies {
                        $0.authClient = .liveValue
                    } operation: {
                        LoginViewModel()
                    })
                    .transition(.opacity)
                case .authenticated:
                    MainTabView()
                        .transition(.opacity)
                }
            }
        }
        .task { viewModel.onAppear() }
    }
}
