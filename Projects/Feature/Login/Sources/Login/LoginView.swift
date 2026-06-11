import SwiftUI

import DesignSystem

public struct LoginView: View {
    @State private var viewModel = LoginViewModel()

    public init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 0) {
            HeroView()
            LoginContentView(viewModel: viewModel)
        }
        .ignoresSafeArea(edges: .top)
        .background(DesignSystemAsset.white.swiftUIColor)
        .sheet(isPresented: $viewModel.isTermsPresented) {
            Text("이용약관")
        }
        .sheet(isPresented: $viewModel.isPrivacyPresented) {
            Text("개인정보 처리방침")
        }
    }
}
