#if DEV_ENVIRONMENT
import Foundation

import DomainInterface

import Dependencies

extension SignInWithDevTestAccountUseCase: DependencyKey {
    public static let liveValue = SignInWithDevTestAccountUseCase(
        execute: {
            @Dependency(\.devTestAccountRepository) var repository
            @Dependency(\.authSessionRepository) var session

            let token = try await repository.signIn()
            try session.setRefreshToken(token.refreshToken)
            await session.setAccessToken(token.accessToken)
        }
    )
}
#endif
