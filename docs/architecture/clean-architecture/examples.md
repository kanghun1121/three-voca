# Clean Architecture — Example Cases

## DataSource는 Data 내부에서 사용한다

Good Case — [AuthRemoteDataSource](../../../Projects/Data/Sources/Auth/AuthRemoteDataSource.swift)가 네트워크 요청을 처리하고, [AuthRepository](../../../Projects/Data/Sources/Auth/AuthRepository+Live.swift)가 응답을 Domain Model로 변환한다.

```swift
// Data: Repository 구현
@Dependency(\.authRemoteDataSource) var remoteDataSource
let dto = try await remoteDataSource.exchangeAppleToken(identityToken)
return dto.toDomain()
```

Bad Case — Feature의 ViewModel이 DataSource를 직접 사용해 응답 모델까지 다룬다.

```swift
// Feature: Data 내부 구현과 응답 모델이 화면에 노출된다.
@Dependency(\.authRemoteDataSource) var remoteDataSource
let dto = try await remoteDataSource.exchangeAppleToken(identityToken)
```

## 단순 조회에는 UseCase를 추가하지 않는다

기준: [clean-architecture.md](../clean-architecture.md)

Good Case — [WordDetailViewModel](../../../Projects/Feature/Word/Sources/WordDetail/WordDetailViewModel.swift)처럼 한 Repository의 결과를 화면 상태로 반영한다.

```swift
@Dependency(\.wordRepository) private var wordRepository

func load(id: String) async throws -> WordDetail {
    try await wordRepository.fetchDetail(id)
}
```

Bad Case — 호출을 그대로 전달하기만 하는 UseCase를 별도로 만든다.

```swift
// 불필요한 중간 계층: 도메인 처리나 호출 조합이 없다.
struct FetchWordDetailUseCase {
    let execute: @Sendable (String) async throws -> WordDetail
}

// 구현도 wordRepository.fetchDetail(id)만 호출한다.
```

여러 Repository 호출을 조합하거나 실행 순서가 의미를 가질 때만 UseCase를 둔다. [`LoadLessonDetailUseCase`](../../../Projects/Domain/Sources/UseCase/LoadLessonDetailUseCase+Live.swift)가 해당한다.

## 외부 모델은 도메인 경계에서 변환한다

Good Case — [WordEntity 매핑](../../../Projects/Data/Sources/LocalDatabase/Entities+Mapping.swift)은 저장 모델을 `WordDetail`로 변환한다. [WordLocalDataSource](../../../Projects/Data/Sources/Word/WordLocalDataSource.swift)는 이 변환을 거친 값을 반환한다.

```swift
// Data 내부
return entity.toWordDetail(examples: examples)
```

Bad Case — 저장 모델을 Feature까지 전달해 ViewModel이 저장 구조를 해석한다.

```swift
// Feature에 저장소 형식이 새어 나온다.
let entity = try await repository.fetchWordEntity(id)
let title = entity.word
```

## 도메인 의미와 화면 표현을 구분한다

Good Case — [Lesson.Word.primaryMeaning](../../../Projects/Domain/Interface/Model/Lesson+PrimaryMeaning.swift)은 화면과 무관한 규칙이다. [WordDetail.groupedDefinitions()](../../../Projects/Feature/Word/Sources/WordDetail/Definition/WordDetail+DefinitionGrouping.swift)는 해당 화면의 표시를 위해 Feature에서 파생한다.

```swift
// DomainInterface: 공통 의미
var primaryMeaning: String { definitions.first?.meaning ?? "" }

// Feature: 화면별 표현
let groups = detail.groupedDefinitions()
```

Bad Case — Domain Model에 화면 전용 색상·라벨을 저장하거나, 같은 데이터를 화면별 모델에 복제한다.

```swift
struct WordPresentationModel {
    let detail: WordDetail
    let copiedDefinitions: [WordDetail.Definition]
    let labelColor: Color
}
```
