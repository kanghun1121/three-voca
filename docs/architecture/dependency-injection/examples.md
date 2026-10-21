# Dependency Injection — Example Cases

## 값 타입 계약과 liveValue

기준: [dependency-injection.md](../dependency-injection.md)

Good Case — 실제 [WordRepository 계약](../../../Projects/Domain/Interface/Repository/WordRepository.swift)은 동작을 담은 `struct`와 `UnimplementedTestDependencyKey`를 사용한다. [Data 구현](../../../Projects/Data/Sources/Word/WordRepository+Live.swift)이 `liveValue`를 제공한다. 아래는 필요한 부분만 발췌한 예시다.

```swift
// Domain/Interface/Repository/WordRepository.swift
@DependencyClient
public struct WordRepository: Sendable {
    public var fetchDetail: @Sendable (_ id: String) async throws -> WordDetail
    public var prefetchDetails: @Sendable (_ ids: [String]) async -> Void
}
extension WordRepository: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var wordRepository: WordRepository {
        get { self[WordRepository.self] }
        set { self[WordRepository.self] = newValue }
    }
}

// Data/Sources/Word/WordRepository+Live.swift
extension WordRepository: DependencyKey {
    public static let liveValue = WordRepository(
        fetchDetail: { id in
            @Dependency(\.wordLocalDataSource) var dataSource
            return try await dataSource.wordDetail(numericID(from: id))
        },
        prefetchDetails: { _ in
            // 이 저장소에서 로컬 DB 조회는 별도 prefetch가 필요 없다.
        }
    )
}
```

Bad Case — 소비하는 객체가 `liveValue`를 직접 보유하면 구현과 결합된다.

```swift
final class WordDetailViewModel {
    private let wordRepository = WordRepository.liveValue
}
```

계약과 구현을 분리하고 객체 간 협력을 의존성 계약으로 연결한다.

## 사례 데이터는 사용하는 곳에 둔다

Good Case — [Home Example의 Mock 파일](../../../Projects/Feature/Home/Example/Mock/LearningHistoryRepository+Mock.swift)에 시나리오를 정의하고, [HomeExampleApp](../../../Projects/Feature/Home/Example/HomeExampleApp.swift)에서 선택해 주입한다. 테스트는 [WordDetailViewModelTests](../../../Projects/Feature/Word/Tests/WordDetailViewModelTests.swift)처럼 해당 테스트에서 필요한 동작을 교체한다.

```swift
// Feature/Home/Example/Mock/LearningHistoryRepository+Mock.swift
extension LearningHistoryRepository {
    static let emptyPath = LearningHistoryRepository(
        stream: { _ in AsyncStream { $0.finish() } },
        streamAllCompletions: { AsyncStream { $0.yield([]); $0.finish() } },
        complete: { _ in }
    )

    // happyPath도 이 Example의 Mock 파일에 정의한다.
}

// Feature/Home/Example/HomeExampleApp.swift
let viewModel = withDependencies {
    $0.learningHistoryRepository = .emptyPath
} operation: {
    HomeViewModel()
}

// Feature/Word/Tests/WordDetailViewModelTests.swift
private enum MockError: Error { case stub }

let viewModel = withDependencies {
    $0.wordRepository.fetchDetail = { _ in throw MockError.stub }
    $0.loggerClient = LoggerClient(debug: { _, _ in }, error: { _, _ in })
} operation: {
    WordDetailViewModel(wordIDs: ["word_766"], initialIndex: 0)
}
```

Bad Case — `Interface/`에 화면 전용 시나리오를 공개한다.

```swift
// Domain/Interface/Repository/LearningHistoryRepository.swift — 사용하지 않는 형태
extension LearningHistoryRepository {
    public static let happyPath = LearningHistoryRepository(/* 화면 전용 데이터 */)
    public static let emptyPath = LearningHistoryRepository(/* 화면 전용 데이터 */)
}
```

`Interface/`는 계약을 공유하는 위치다. Example·테스트 시나리오는 그 소비처의 파일에 두어 다른 화면의 데이터가 계약으로 확산되지 않게 한다.
