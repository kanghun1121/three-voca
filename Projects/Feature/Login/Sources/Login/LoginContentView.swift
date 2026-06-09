import SwiftUI

struct LoginContentView: View {
    let viewModel: LoginViewModel

    var body: some View {
        VStack(spacing: 0) {
            ValueSectionView()
            LegalTextView(onTermsTapped: viewModel.termsTapped, onPrivacyTapped: viewModel.privacyTapped)
                .padding(.top, 24)
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 28)
        .padding(.top, 8)
    }
}
