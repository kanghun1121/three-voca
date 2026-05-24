# FRONTEND.md

SwiftUI 코드를 작성하기 전에 읽는 규칙.  

---

## 상태 관리

- 공유 상태는 `@Observable` + `@MainActor` 클래스로 관리한다. `@MainActor` 누락 금지.
- `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`는 사용하지 않는다.
- `@State`는 `private`으로 선언하고, 해당 View만 소유한다.
- View 간 전달은 `@Bindable` 또는 `@Environment`를 사용한다.
- `Binding(get:set:)`을 View body에서 직접 만들지 않는다. `onChange()`로 대신한다.

## ViewModel

- ViewModel은 `@Observable @MainActor final class`로 선언한다.
- `@Dependency`는 반드시 `@ObservationIgnored`와 함께 쓴다.

```swift
@Observable
@MainActor
final class HomeViewModel {
    @ObservationIgnored
    @Dependency(\.homeClient) private var homeClient
}
```

- 비즈니스 로직은 ViewModel 메서드로 분리한다. `task()`, `onAppear()` body에 인라인으로 쓰지 않는다.
- 비동기 작업은 `task()` modifier를 사용한다. `onAppear()`에 `Task { }` 래핑 금지.

## View 구조

- `body`가 길어지면 computed property나 `@ViewBuilder` 메서드가 아닌 **별도 View struct**로 분리한다.
- 분리한 View는 각각 독립된 파일에 둔다. 한 파일에 여러 타입 정의 금지.
- Button action은 body에서 클로저로 인라인 작성하지 않고 ViewModel 메서드로 뺀다.

```swift
// 금지
Button("저장") { viewModel.items.append(item); viewModel.isSaved = true }

// 올바름
Button("저장", action: viewModel.saveTapped)
```

## 내비게이션

- `NavigationView` 사용 금지. `NavigationStack` 또는 `NavigationSplitView`를 사용한다.
- 내비게이션 목적지는 `navigationDestination(for:)` 또는 `navigationDestination(item:)`을 사용한다.
- `NavigationLink(destination:)` 패턴 금지.
- 내비게이션 상태는 ViewModel의 `enum Destination`으로 관리한다. (`ARCHITECTURE.md` 참고)

## 성능

- 조건부 modifier는 `if/else` 분기 대신 삼항 연산자를 쓴다. 구조적 동일성 유지.

```swift
// 금지 — _ConditionalContent 생성, 뷰 재생성
if isSelected { Text("A").bold() } else { Text("A") }

// 올바름
Text("A").bold(isSelected)
```

- `AnyView` 사용 금지. `@ViewBuilder`, `Group`, 제네릭으로 대체한다.
- `List` / `ForEach` initializer 안에서 `filter`, `sorted` 등 inline transform 금지.
- 대량 데이터 `ScrollView`에는 `LazyVStack` / `LazyHStack`을 사용한다.

## Swift 규칙

- `async`/`await`이 있으면 클로저 기반 API 사용 금지.
- `DispatchQueue` 사용 금지. Swift Concurrency만 사용한다.
- force unwrap(`!`) 금지. `guard let`, `if let`, nil-coalescing으로 대체한다.
- `if let value = value {` 대신 `if let value {` 단축 문법을 쓴다.
- 단일 표현식 함수에서 `return` 생략한다.
- `String(format: "%.2f", value)` 금지. `FormatStyle` API를 사용한다.
- `CGFloat` 대신 `Double`을 사용한다 (optional, inout 제외).
- `Date()` 대신 `Date.now`를 사용한다.
- 숫자 포맷은 `Text(value, format: .number)` 형태를 사용한다.
