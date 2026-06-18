import SwiftUI

import Domain
import DomainInterface
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
                MainTabView()
            }
        }
        .task { viewModel.onAppear() }
    }
}
