import SwiftUI

import Domain
import DomainInterface
import FeatureLogin

import Dependencies

struct RootView: View {
    @State private var viewModel = AppViewModel()
    @State private var showLaunch = true

    var body: some View {
        Group {
            if showLaunch {
                LaunchScreen()
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
        .task {
            viewModel.onAppear()
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.easeInOut(duration: 0.4)) {
                showLaunch = false
            }
        }
    }
}
