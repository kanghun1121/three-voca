import Foundation

import DomainInterface

import Dependencies

extension SeedRepository: DependencyKey {
    public static let liveValue = SeedRepository(
        syncIfNeeded: {
            @Dependency(\.seedLocalDataSource) var localDataSource
            @Dependency(\.seedRemoteDataSource) var remoteDataSource

            guard try await localDataSource.isEmpty() else { return }
            try await localDataSource.save(try await remoteDataSource.fetchSeedData())
        }
    )
}
