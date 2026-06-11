import SwiftUI

struct LoginContentView: View {
    let viewModel: LoginViewModel

    var body: some View {
        VStack(spacing: 0) {
            ValueSectionView()
            AppleLoginButtonView(viewModel: viewModel)
                .padding(.top, 24)
            LegalTextView(onTermsTapped: viewModel.termsTapped, onPrivacyTapped: viewModel.privacyTapped)
                .padding(.top, 4)
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 28)
        .padding(.top, 8)
    }
}
