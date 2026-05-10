# Layer Rules — Feature 레이어 모델 3계층 상세 스펙

이 문서는 `swift-feature-mvvm-layers` 스킬의 핵심 규칙 문서다. Feature 코드를 작성하기 전에 통독한다.

## 목차

- §1. DTO (Data Transfer Object)
- §2. Domain Model
- §3. Display Model
- §4. 절대 규칙 (위반 시 작업 중단)
- §5. 네이밍 컨벤션
- §6. 변환 규칙

---

## §1. DTO (Data Transfer Object) — 서버 응답 모델

### 역할
서버 응답(JSON 등)을 1:1로 매핑한 형태.

### 소유 위치
Core / Domain 모듈의 Repository **구현부에서만** 다룬다. **Feature 레이어 코드에 DTO가 직접 등장하면 안 된다.**

### 특징
- `Codable` 채택. 프로퍼티 이름·타입은 서버 스펙 그대로.
  - 서버가 `String`으로 내려보내는 시간은 `String`으로 둔다. `Date`로 자동 변환하지 않는다.
  - 서버가 코드값(`"ADMIN"`, `0`, `1`)으로 내려보내는 enum 후보는 `String`/`Int` 그대로.
- 비즈니스 가공·기본값 보정·계산 프로퍼티 **금지**. 파싱만 담당.
- `toDomain()` 매퍼 메서드를 한 곳에 모은다 (보통 별도 파일).

### 네이밍
`XxxDTO` 또는 `XxxResponse` (예: `UserDTO`, `LoginResponse`).

### 안티패턴
```swift
// ❌ DTO에 비즈니스 로직
extension UserDTO {
    var isAdult: Bool { age >= 19 }   // 비즈니스 판단은 Domain Model로
}

// ❌ DTO를 Repository 외부로 노출
public protocol UserRepository {
    func fetchUser(id: Int) async throws -> UserDTO   // Domain Model을 반환해야 함
}
```

---

## §2. Domain Model — 도메인 모델

### 역할
비즈니스 로직에서 사용하는 애플리케이션 내부 표준 모델.

### 소유 위치
Domain 모듈의 Interface 타겟에서 정의. Feature 레이어가 import해서 사용한다.

### 특징
- DTO에서 필요한 필드만 추려, 로직 처리에 적합한 타입으로 변환:
  - ISO8601 문자열 → `Date`
  - 코드값(문자열·정수) → `enum`
  - nullable 처리·기본값 결정
- View·서버 표현에 의존하지 않는 순수한 도메인 표현
- 화면용 포매팅 프로퍼티(`formattedPrice`, `displayName` 등) **금지**
- 비즈니스 판단 메서드/프로퍼티는 허용 (`isExpired`, `canRefund` 등)

### 네이밍
도메인 명사 그대로 (예: `User`, `Post`, `PaymentOrder`, `LoginResult`).

### 안티패턴
```swift
// ❌ 화면용 포매팅이 Domain에 섞임
public struct User {
    public let createdAt: Date
    public var formattedJoinDate: String {   // Display Model로 가야 함
        DateFormatter.localizedString(from: createdAt, dateStyle: .medium, timeStyle: .none)
    }
}

// ❌ View 의존 타입이 Domain에 들어옴
public struct User {
    public let badgeColor: Color   // SwiftUI Color는 Domain에 있으면 안 됨
}
```

---

## §3. Display Model — 화면 표시 모델

### 역할
View가 그대로 그릴 수 있는 화면용 데이터 모델.

### 소유 위치
Feature 모듈 내부 (`Sources/` 안). View와 ViewModel(클래스)이 공유한다.

### 특징
- 모든 값이 **화면 표시에 적합한 형태**:
  - `Date` → 포맷된 `String` (예: `"2024년 12월 28일"`)
  - 금액 `Int` → `"₩12,000"` 형태의 `String`
  - 상태 `enum` → 표시 문구·색상 토큰 식별자
- View는 이 모델만 보고, 추가 가공·분기 없이 바로 렌더한다
- `Equatable` 채택 권장 (SwiftUI `@Published` 변경 감지·테스트 시 유용)

### 네이밍
`XxxViewState`, `XxxDisplayModel`, `XxxItem` 중 한 가지를 모듈 내에서 일관되게 사용.

**중요**: MVVM의 `ViewModel` *클래스*와 혼동되지 않도록 데이터 모델에는 `ViewModel`이라는 접미사를 쓰지 않는다.
- 클래스: `XxxViewModel` (`final class`, `ObservableObject`)
- 데이터 모델: `XxxViewState` (`struct`, `Equatable`)

### 안티패턴
```swift
// ❌ Display Model에 Date 그대로
struct ProfileViewState {
    let joinedAt: Date   // String으로 포매팅해서 보유해야 함
}

// ❌ Display Model이 Domain Model 통째로 보유
struct ProfileViewState {
    let user: User   // 평탄화해서 필요한 필드만 풀어두기
}

// ❌ 모든 화면이 한 모델을 공유
struct UserDisplayModel { ... }   // 프로필·목록·검색결과를 한 모델로 → 분리
```

---

## §4. 절대 규칙

다음 규칙은 위반 시 **코드 작성을 중단하고 사용자에게 확인**한다.

1. **View는 DTO와 Domain Model을 직접 알지 못한다.**
   View가 import 또는 참조하는 데이터 타입은 Display Model뿐이다.

2. **Repository protocol의 반환 타입은 Domain Model.**
   DTO를 외부로 노출하지 않는다.

3. **Domain Model에 화면용 프로퍼티를 추가하지 않는다.**
   `formattedDate`, `displayPrice` 같은 프로퍼티는 Display Model에 둔다.

4. **DTO에 비즈니스 로직 메서드를 추가하지 않는다.**
   `toDomain()` 매퍼만 허용.

5. **3계층이 동일해 보여도 타입을 합치지 않는다.**
   한 필드짜리 모델이라도 분리. 변경 주체가 다르므로 (서버 스펙·도메인 정책·디자인) 분리를 유지한다.

6. **변환은 명시적 매퍼로 작성한다.**
   `extension`을 통해 메서드를 두고, 자동 변환·런타임 캐스팅으로 처리하지 않는다.

7. **ViewModel 클래스는 Domain Model을 직접 노출하지 않는다.**
   `@Published var user: User` ❌ → `@Published var state: ProfileViewState?` ✅

---

## §5. 네이밍 컨벤션

모듈 내에서 한 가지 컨벤션을 일관되게 사용. 권장:

| 계층 | 권장 접미사 | 예시 |
|------|------------|------|
| DTO | `DTO` 또는 `Response` | `UserDTO`, `LoginResponse` |
| Domain Model | 도메인 명사 | `User`, `LoginResult` |
| Display Model | `ViewState` (권장) | `LoginViewState`, `ProfileViewState` |
| Display Model — 리스트 셀 | `Item` | `UserListItem`, `PostFeedItem` |
| ViewModel 클래스 | `ViewModel` | `LoginViewModel` |
| DTO → Domain 매퍼 | `toDomain()` | `extension UserDTO { func toDomain() -> User }` |
| Domain → Display 매퍼 | `toXxxViewState()` / `toXxxItem()` | `func toProfileViewState() -> ProfileViewState` |

---

## §6. 변환 규칙

### 어디서 변환하는가

| 변환 | 위치 |
|------|------|
| DTO → Domain Model | Repository 구현부 (Core 또는 Domain Implements) |
| Domain Model → Display Model | Feature 모듈의 ViewModel 클래스 |

### 변환 함수의 형태

- **항상 `extension`으로 정의**한다. 별도 매퍼 클래스를 만들지 않는다.
- **순수 함수**여야 한다. 외부 상태를 읽거나 부수효과를 일으키면 안 된다.
- 예외: 날짜 포매팅 등 무거운 객체는 `private static let`으로 캐싱.

### 변환을 어디서 호출하는가

```swift
// Repository 구현부
public func fetchUser(id: Int) async throws -> User {
    let dto: UserDTO = try await network.request(...)
    return dto.toDomain()
}

// Feature의 ViewModel 클래스
func load(userID: Int) async {
    let user: User = try await userService.fetchUser(id: userID)
    state = user.toProfileViewState()
}
```

ViewModel이 Display Model로 변환하는 시점은 **Service 호출 직후**. View가 그릴 때 변환하지 않는다.
