# Code Templates — Feature 레이어 모델 3계층 코드 예시

이 문서는 `swift-feature-mvvm-layers` 스킬이 코드 작성 단계에서 참조하는 템플릿이다.

각 템플릿을 그대로 복사하지 말고, 도메인·화면 컨텍스트에 맞춰 패턴을 따른다.

## 목차

- §A. DTO
- §B. DTO → Domain 매퍼
- §C. Domain Model
- §D. Display Model
- §E. Domain → Display 매퍼
- §F. ViewModel 클래스
- §G. View
- §H. 매퍼 작성 시 패턴 정리

---

## §A. DTO (Core 또는 Domain Implements 레이어)

```swift
// Core/Network/Sources/User/UserDTO.swift
import Foundation

struct UserDTO: Decodable {
    let id: Int
    let name: String
    let email: String
    let createdAt: String   // 서버가 내려주는 ISO8601 문자열 그대로
    let role: String        // 코드값 그대로 ("ADMIN", "MEMBER", "GUEST")
}
```

**핵심**:
- `internal` (또는 `fileprivate`) 접근 제어. `public` 금지.
- `Codable`이 아니라 `Decodable` (응답 전용이면 충분).
- 서버 필드명과 다르면 `CodingKeys` 사용. 임의 변환 금지.

---

## §B. DTO → Domain 매퍼

```swift
// Core/Network/Sources/User/UserDTO+Mapping.swift
import Foundation
import DomainUserInterface

extension UserDTO {
    func toDomain() -> User {
        User(
            id: id,
            name: name,
            email: email,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? .distantPast,
            role: UserRole(rawValue: role) ?? .member
        )
    }
}
```

**핵심**:
- DTO가 정의된 모듈 내부에 둔다.
- 잘못된 값에 대한 폴백을 명시 (`?? .distantPast`, `?? .member`). 강제 언래핑 금지.
- ISO8601 같은 무거운 포매터는 사용 빈도 높으면 `static let`으로 캐싱.

---

## §C. Domain Model (Domain Interface)

```swift
// Domain/User/Interface/User.swift
import Foundation

public struct User: Equatable {
    public let id: Int
    public let name: String
    public let email: String
    public let createdAt: Date
    public let role: UserRole

    public init(
        id: Int,
        name: String,
        email: String,
        createdAt: Date,
        role: UserRole
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = createdAt
        self.role = role
    }
}

public enum UserRole: String {
    case admin
    case member
    case guest
}
```

**핵심**:
- `public` (모듈 경계 통과). `init`도 `public`.
- `Equatable` 권장.
- 화면용 포매팅 프로퍼티 금지. 비즈니스 판단 프로퍼티는 허용 (`var isExpired: Bool`).

---

## §D. Display Model (Feature 내부)

```swift
// Feature/Profile/Sources/Profile/ProfileViewState.swift
import Foundation

struct ProfileViewState: Equatable {
    let name: String
    let email: String
    let joinedDateText: String       // "2024년 12월 28일 가입"
    let roleBadgeText: String        // "관리자" / "회원"
    let roleBadgeColorToken: String  // 디자인 토큰 식별자
}
```

**핵심**:
- `internal` 접근 제어 (Feature 모듈 내부 전용).
- `Equatable` 채택. SwiftUI `@Published` 변경 감지·테스트 비교에 유용.
- 모든 필드가 화면 표시에 적합한 형태. `Date` → `String`, `Color` → 토큰 식별자.

---

## §E. Domain → Display 매퍼 (Feature 내부)

```swift
// Feature/Profile/Sources/Profile/User+ProfileViewState.swift
import Foundation
import DomainUserInterface

extension User {
    func toProfileViewState() -> ProfileViewState {
        ProfileViewState(
            name: name,
            email: email,
            joinedDateText: Self.dateFormatter.string(from: createdAt) + " 가입",
            roleBadgeText: role.displayText,
            roleBadgeColorToken: role.colorToken
        )
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일"
        return f
    }()
}

private extension UserRole {
    var displayText: String {
        switch self {
        case .admin: return "관리자"
        case .member: return "회원"
        case .guest: return "게스트"
        }
    }

    var colorToken: String {
        switch self {
        case .admin: return "badge.admin"
        case .member: return "badge.member"
        case .guest: return "badge.guest"
        }
    }
}
```

**핵심**:
- Feature 모듈 내부에 둔다.
- `private extension`으로 내부 헬퍼를 묶어둔다 — 외부에 노출되면 Domain Model 오염 위험.
- 포매터는 `private static let`로 캐싱.

---

## §F. ViewModel 클래스 (Feature 내부)

```swift
// Feature/Profile/Sources/Profile/ProfileViewModel.swift
import Foundation
import DomainUserInterface

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var state: ProfileViewState?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let userService: UserServiceInterface

    init(userService: UserServiceInterface) {
        self.userService = userService
    }

    func load(userID: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let user: User = try await userService.fetchUser(id: userID)  // Domain Model
            state = user.toProfileViewState()                              // Display Model로 변환
        } catch {
            errorMessage = "프로필을 불러오지 못했습니다."
        }
    }
}
```

**핵심**:
- `@MainActor` (UI 갱신 안전).
- `final class` (상속 금지).
- `@Published` 프로퍼티는 모두 Display Model 또는 화면용 원시값 (`isLoading`, `errorMessage`). **Domain Model을 노출하지 않는다.**
- `private(set)` (외부 직접 변경 금지).
- 의존성은 `init` 주입 (Service Interface 타입).

---

## §G. View (Feature 내부, Display Model만 본다)

```swift
// Feature/Profile/Sources/Profile/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    let userID: Int

    var body: some View {
        Group {
            if let state = viewModel.state {
                content(state)
            } else if viewModel.isLoading {
                ProgressView()
            } else if let message = viewModel.errorMessage {
                Text(message)
            }
        }
        .task { await viewModel.load(userID: userID) }
    }

    private func content(_ state: ProfileViewState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(state.name).font(.title)
            Text(state.email).foregroundStyle(.secondary)
            Text(state.joinedDateText)
            Text(state.roleBadgeText)
        }
    }
}
```

**핵심**:
- `import DomainUserInterface` 같은 도메인 모듈 import **금지**. View는 Display Model만 본다.
- View 안에서 `DateFormatter`, `NumberFormatter` 사용 금지. 그건 매퍼의 일.
- `content(state)`처럼 Display Model을 받는 서브뷰로 분리하면 Preview 작성도 쉬워진다.

---

## §H. 매퍼 작성 시 패턴 정리

### 매퍼 위치 정리

| 매퍼 | 파일 위치 | 접근 제어 |
|------|----------|----------|
| `UserDTO.toDomain() -> User` | DTO와 같은 모듈 | `internal` |
| `User.toProfileViewState() -> ProfileViewState` | Feature 모듈 내부 | `internal` |
| `User.toUserListItem() -> UserListItem` | Feature 모듈 내부 | `internal` |

### 한 Domain Model에서 여러 Display Model로 매핑

같은 `User`를 프로필 화면, 목록 셀, 검색 결과에서 다르게 표현해야 할 때:

```swift
// Feature/Profile/Sources/.../User+ProfileViewState.swift
extension User {
    func toProfileViewState() -> ProfileViewState { ... }
}

// Feature/UserList/Sources/.../User+UserListItem.swift
extension User {
    func toUserListItem() -> UserListItem { ... }
}

// Feature/Search/Sources/.../User+UserSearchResultItem.swift
extension User {
    func toUserSearchResultItem() -> UserSearchResultItem { ... }
}
```

각 Feature 모듈이 자기 화면에 맞는 매퍼를 소유한다. **Domain 모듈에는 어떤 매퍼도 두지 않는다.**

### 여러 Domain Model을 합쳐서 한 Display Model로

```swift
struct OrderDetailViewState: Equatable {
    let orderTitle: String
    let buyerName: String
    let totalAmountText: String
}

extension OrderDetailViewState {
    static func make(order: Order, buyer: User, currency: Currency) -> Self {
        Self(
            orderTitle: order.title,
            buyerName: buyer.name,
            totalAmountText: currency.format(order.totalAmount)
        )
    }
}
```

매퍼 인자가 2개 이상이면 `extension Domain` 보다 `extension Display.make(...)` 정적 팩토리를 권장.
