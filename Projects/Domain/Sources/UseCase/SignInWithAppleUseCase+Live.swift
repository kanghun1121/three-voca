import Foundation

import DomainInterface

import Dependencies

extension SignInWithAppleUseCase: DependencyKey {
    public static let liveValue = SignInWithAppleUseCase(
        execute: { identityToken in
            @Dependency(\.authRepository) var authRepository
            @Dependency(\.authSessionRepository) var authSessionRepository

            let token = try await authRepository.signInWithApple(identityToken)
            await authSessionRepository.setAccessToken(token.accessToken)
            try authSessionRepository.setRefreshToken(token.refreshToken)
            return token
        }
    )
}
