import AuthenticationServices
import Foundation

import DomainInterface

import Dependencies

@Observable
@MainActor
public final class LoginViewModel {
    var isTermsPresented = false
    var isPrivacyPresented = false

    @ObservationIgnored @Dependency(\.authClient) private var authClient
    
    public init() {}

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
                  let tokenData = credential.identityToken,
                  let identityToken = String(data: tokenData, encoding: .utf8) else { return }
            Task {
                do {
                    _ = try await authClient.signInWithApple(identityToken)
                } catch {
                    print("[AuthClient] error:", error.localizedDescription)
                }
            }
        case .failure(let error):
            print("[Apple Login] error:", error.localizedDescription)
        }
    }
}
