import AuthenticationServices
import Foundation

import Core
import DomainInterface

import Dependencies

@Observable
@MainActor
public final class LoginViewModel {
    var isTermsPresented = false
    var isPrivacyPresented = false

    @ObservationIgnored @Dependency(\.signInWithAppleUseCase) private var signInWithAppleUseCase
    @ObservationIgnored @Dependency(\.loggerClient) private var loggerClient
    
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
                    _ = try await signInWithAppleUseCase.execute(identityToken)
                } catch {
                    loggerClient.error("Auth", "signInWithApple 실패: \(error.localizedDescription)")
                }
            }
        case .failure(let error):
            loggerClient.error("Auth", "Apple 로그인 실패: \(error.localizedDescription)")
        }
    }
}
