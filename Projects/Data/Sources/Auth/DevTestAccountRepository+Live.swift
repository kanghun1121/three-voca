#if DEV_ENVIRONMENT
import Foundation

import DomainInterface
import NetworkingInterface

import Dependencies

extension DevTestAccountRepository: DependencyKey {
    public static let liveValue = DevTestAccountRepository(
        signIn: {
            @Dependency(\.authRemoteDataSource) var remoteDataSource
            let dto = try await remoteDataSource.signInWithDevTestAccount()
            return dto.toDomain()
        }
    )
}
#endif
