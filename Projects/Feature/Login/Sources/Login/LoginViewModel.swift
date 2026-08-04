import AuthenticationServices
import Foundation
import OSLog

import DomainInterface

import Dependencies

private let logger = Logger(subsystem: "com.kangdev.FiveVoca", category: "Auth")

@Observable
@MainActor
public final class LoginViewModel {
    var isTermsPresented = false
    var isPrivacyPresented = false

    @ObservationIgnored @Dependency(\.signInWithAppleUseCase) private var signInWithAppleUseCase
    
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
                    logger.error("signInWithApple 실패: \(error.localizedDescription)")
                    print("[SignInWithAppleUseCase] error:", error.localizedDescription)
                }
            }
        case .failure(let error):
            logger.error("Apple 로그인 실패: \(error.localizedDescription)")
            print("[Apple Login] error:", error.localizedDescription)
        }
    }
}
