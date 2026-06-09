import SwiftUI

import DesignSystem

public struct LoginView: View {
    @State private var viewModel = LoginViewModel()

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            HeroView()

            VStack(spacing: 0) {
                ValueSectionView()

                LegalTextView(
                    onTermsTapped: viewModel.termsTapped,
                    onPrivacyTapped: viewModel.privacyTapped
                )
                .padding(.top, 24)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 28)
            .padding(.top, 8)
        }
        .ignoresSafeArea(edges: .top)
        .background(.white)
    }
}
