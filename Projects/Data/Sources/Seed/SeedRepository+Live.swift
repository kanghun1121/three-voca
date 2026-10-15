import Foundation

import DomainInterface

import Dependencies

extension SeedRepository: DependencyKey {
    public static let liveValue = SeedRepository(
        syncIfNeeded: {
            @Dependency(\.levelLocalDataSource) var level
            @Dependency(\.wordLocalDataSource) var word
            @Dependency(\.lessonLocalDataSource) var lesson
            @Dependency(\.localDatabaseContext) var context
            @Dependency(\.seedRemoteDataSource) var remoteDataSource

            // 레벨이 하나라도 있으면 시드가 이미 들어와 있다 — 전체를 한 번의 save로 커밋하므로
            // 일부만 저장된 상태는 생기지 않는다.
            guard try await level.allLevels().isEmpty else { return }

            let response = try await remoteDataSource.fetchSeedData()
            try await LocalDatabaseSeeder.seed(
                response,
                word: word,
                lesson: lesson,
                level: level,
                context: context
            )
        }
    )
}
