import AuthenticationServices
import Foundation

@Observable
@MainActor
final class LoginViewModel {
    var isTermsPresented = false
    var isPrivacyPresented = false

    func termsTapped() {
        isTermsPresented = true
    }

    func privacyTapped() {
        isPrivacyPresented = true
    }

    func appleLoginRequested(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func appleLoginCompleted(_ result: Result<ASAuthorization, any Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = credential.identityToken else { return }
            print(identityToken.base64EncodedString())
        case .failure(let error):
            print("[Apple Login] error: \(error.localizedDescription)")
        }
    }
}
