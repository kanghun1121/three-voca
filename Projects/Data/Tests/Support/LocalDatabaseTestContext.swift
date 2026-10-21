import SwiftData

import Dependencies

@testable import Data

/// in-memory `LocalDatabaseContext` 생성 + `withDependencies` 주입 + 픽스처 커밋을 한 곳에 모은다.
/// 각 테스트 파일이 반복 정의하던 `makeContext()` + `withDependencies { ... }` 보일러플레이트를 대체한다.
struct LocalDatabaseTestContext {
    let context: LocalDatabaseContext

    init() {
        context = LocalDatabaseContext(modelContainer: LocalDatabaseSchema.makeInMemoryContainer())
    }

    /// 픽스처를 삽입하고 즉시 커밋한다 — insert 후 save를 빼먹어 조회가 비는 실수를 막는다.
    func seed(_ models: any PersistentModel...) async throws {
        for model in models {
            await context.insert(model)
        }
        try await context.save()
    }

    /// `localDatabaseContext`와 그걸 쓰는 로컬 DataSource들을 `.liveValue`로 주입한 채
    /// operation을 실행한다. `#122`부터 `testValue`가 전부 `unimplemented`가 되어, 여기서
    /// 명시적으로 `.liveValue`를 주입하지 않으면(XCTest 기본 동작상 미오버라이드 의존성은
    /// `testValue`로 해석됨) `LessonRepository.liveValue`처럼 이 DataSource들을 간접
    /// 사용하는 상위 계층 테스트가 트랩된다.
    func run<T>(_ operation: () async throws -> T) async throws -> T {
        try await withDependencies {
            $0.localDatabaseContext = context
            $0.wordLocalDataSource = .liveValue
            $0.levelLocalDataSource = .liveValue
            $0.lessonLocalDataSource = .liveValue
            $0.learningHistoryLocalDataSource = .liveValue
            $0.chatHistoryLocalDataSource = .liveValue
        } operation: {
            try await operation()
        }
    }

    /// 회귀 가드용 카운트 조회.
    func count<T: PersistentModel>(_ type: T.Type) async throws -> Int {
        try await context.fetch(FetchDescriptor<T>()).count
    }
}
