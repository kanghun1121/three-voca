import AuthenticationServices
import SwiftUI

struct AppleLoginButtonView: View {
    let viewModel: LoginViewModel

    var body: some View {
        SignInWithAppleButton(
            .continue,
            onRequest: viewModel.appleLoginRequested,
            onCompletion: viewModel.appleLoginCompleted
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 54)
        .clipShape(.rect(cornerRadius: 12))
    }
}
