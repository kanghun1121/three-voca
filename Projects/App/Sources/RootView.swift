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
            } else {
                switch viewModel.authState {
                case .unauthenticated:
                    LoginView(viewModel: withDependencies {
                        $0.signInWithAppleUseCase = .liveValue
                    } operation: {
                        LoginViewModel()
                    })
                case .authenticated:
                    MainTabView()
                }
            }
        }
        .task { viewModel.onAppear() }
    }
}
