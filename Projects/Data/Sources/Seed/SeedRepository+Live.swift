import Foundation

import DomainInterface

import Dependencies

extension SeedRepository: DependencyKey {
    public static let liveValue = SeedRepository(
        syncIfNeeded: {
            @Dependency(\.seedLocalDataSource) var local
            @Dependency(\.seedRemoteDataSource) var remote

            guard try await local.isEmpty() else { return }
            try await local.save(try await remote.fetchSeedData())
        }
    )
}
