# Dependency Injection

의존성의 계약과 구현을 분리하고, 조립 위치를 정한다.

## 원칙

- 의존성 계약은 값 타입을 기반으로 작성한다. 필요한 동작은 계약에 정의하고 구현과 분리한다.
- 객체 간 직접적인 의존은 허용하지 않는다. 협력은 의존성 계약을 통해 연결한다.
- 등록하는 의존성에는 `liveValue`를 필수로 작성하고, 구현을 소유한 모듈에 둔다.
- 값 타입 의존성 계약은 `UnimplementedTestDependencyKey`를 사용한다.
- `happyPath`, `emptyPath` 같은 Example 데이터와 테스트 데이터는 각각 사용하는 Example·Tests 파일에 둔다. `Interface/`에는 선언하지 않는다.
- 실제 앱, Example, 테스트는 각자의 조립 지점에서 필요한 구현과 사례 데이터를 연결한다.

Example Cases: [Dependency Injection 예시](dependency-injection/examples.md)
