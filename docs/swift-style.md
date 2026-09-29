# SwiftUI 작성 규칙

SwiftUI View를 어떻게 작성하는지 정한다. Swift 일반 규칙(네이밍·포맷·코드)과 검토 등급·검사 방법은 [lint.md](lint.md)를 따른다.
신규·수정 코드의 작성 기준이며, 기존 코드가 모두 준수한다는 설명은 아니다. 요청과 무관한 일괄 변경은 하지 않는다.

## 규칙

아래 View 분리·컨테이너 개수 규칙은 이 저장소의 프로젝트 규칙이다.

- 화면 구성 단위는 별도 `View` struct로 정의한다.
- 하위 화면 조각을 `@ViewBuilder` 함수·computed property로 추출하는 방식은 지양한다.
- 한 View struct의 레이아웃 컨테이너는 최대 1개로 제한하고 추가 컨테이너는 하위 View struct로 분리한다.
- 대상 컨테이너에는 `VStack`, `HStack`, `ZStack`, `Grid`, `LazyVStack`, `LazyHStack` 등이 포함된다.
- 하위 View는 의미 있는 화면 구성 단위로 이름 짓고, 필요한 값·Binding·이벤트만 전달한다.
- `@State`는 `private`으로 선언한다.
- modifier가 3개 이상 이어지면 한 줄에 하나씩 작성한다.
- 반복되는 modifier 묶음은 `ViewModifier` 등으로 추출하기를 권장한다.
- 상태·데이터 흐름·내비게이션의 책임은 [architecture.md](architecture.md)를 따른다.
