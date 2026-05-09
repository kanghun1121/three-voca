# Architecture Rules

> 본 스킬이 참조하는 Tuist MicroFeature 아키텍처의 단일 원천 룰.
> 참조 모델: `depromeet/Pumping-iOS`.

## 1. 디렉토리 구조

```
ProjectRoot/
├── Plugins/
│   └── DependencyPlugin/
│       ├── Package.swift
│       └── ProjectDescriptionHelpers/
│           ├── ModulePath/
│           │   ├── ModulePath.swift
│           │   ├── ModulePath+Feature.swift
│           │   ├── ModulePath+Domain.swift
│           │   ├── ModulePath+Core.swift
│           │   └── ModulePath+Shared.swift
│           ├── Project+Templates/
│           ├── Target+Templates/
│           │   ├── Target+Feature.swift
│           │   ├── Target+Domain.swift
│           │   ├── Target+Core.swift
│           │   └── Target+Shared.swift
│           └── Dependency+Modules.swift
├── Projects/
│   ├── App/
│   ├── Feature/
│   │   ├── Project.swift              ← Feature 레이어 aggregator
│   │   ├── Home/                      ← 서브 Feature
│   │   │   ├── Project.swift
│   │   │   ├── Sources/
│   │   │   ├── Interface/
│   │   │   ├── Testing/
│   │   │   ├── Tests/
│   │   │   └── Example/
│   │   └── Settings/
│   ├── Domain/
│   │   ├── Project.swift
│   │   └── Auth/, User/, ...
│   ├── Core/
│   │   ├── Project.swift
│   │   └── Network/, Database/, ...
│   └── Shared/
│       ├── Project.swift
│       └── DesignSystem/, Util/, ...
├── Tuist/Config.swift
├── Workspace.swift
└── Makefile
```

## 2. 4 Layer 정의

| 레이어 | 책임 | 예시 |
|--------|------|------|
| **Feature** | 화면, ViewModel, 사용자 인터랙션 | `Feature/Home`, `Feature/Settings` |
| **Domain** | UseCase, Entity, Repository protocol, 비즈니스 로직 | `Domain/Auth`, `Domain/User` |
| **Core** | 인프라 구현, 네트워크, 로컬 DB, 로깅 | `Core/Network`, `Core/Database` |
| **Shared** | DesignSystem, 공용 Util, Extension, 외부 라이브러리 래퍼 | `Shared/DesignSystem` |

### 레이어 최상위 모듈 (Aggregator)

각 레이어는 자기 이름의 최상위 모듈을 가진다.

- `Feature` → 하위 Feature들의 Implements + 다음 레이어(`Domain`) 의존
- `Domain` → 하위 Domain들의 Implements + `Core` 의존
- `Core` → 하위 Core들의 Implements + `Shared` 의존
- `Shared` → 하위 Shared들의 Implements

App은 `Feature` 최상위 1개만 의존하면 모든 모듈이 따라온다.

## 3. 5 Target Type 정의

각 서브 모듈이 가질 수 있는 타겟 종류.

| 타입 | 책임 | Product | 의존 |
|------|------|---------|------|
| **Interface** | public protocol/model. 외부 노출 API | framework | (없음) 또는 다른 모듈 Interface |
| **Implements** | 실제 구현. Interface conform | framework | 자기 Interface + 같은 레이어 다른 모듈 Interface |
| **Testing** | 다른 모듈 테스트가 사용할 Mock/Stub | framework | 자기 Interface |
| **Tests** | 단위 테스트 | unitTests | 자기 Implements + 자기 Testing |
| **Example** | 모듈 단독 실행 데모 앱 | app | 자기 Implements + 자기 Interface |

### 타겟 생성 규칙

- 모든 모듈이 5개를 다 가질 필요는 없음
- 최소 필수: `Interface` + `Implements`
- UI 있는 모듈(Feature 거의 전부): `Example` 권장
- 다른 모듈이 mock으로 쓸 가능성: `Testing`
- 단위 테스트 작성: `Tests`
- 화면 없는 leaf 모듈(예: `Shared/Extension`): Interface 생략 가능

### 한 모듈 내부 의존 그래프

```
        ┌─────────────┐
        │  Interface  │ ◀──────┐
        └─────┬───────┘        │
              │                │
        ┌─────┴───────┐        │
        │ Implements  │        │
        └─────┬───────┘        │
              │                │
   ┌──────────┼─────────┐      │
   ▼          ▼         ▼      │
┌──────┐  ┌──────┐  ┌──────┐   │
│Tests │  │Test- │  │Exam- │───┘
│      │  │ing   │  │ple   │
└──────┘  └──────┘  └──────┘
```

## 4. 의존 규칙 (가장 중요)

### 4.1 허용되는 의존

| From | To | 예시 |
|------|----|----|
| 자기 Implements | 자기 Interface | `FeatureHome` → `FeatureHomeInterface` ✅ |
| Implements (A) | 같은 레이어 다른 모듈 Interface (B) | `FeatureHome` → `FeatureProfileInterface` ✅ |
| Interface (A) | 하위 레이어 최상위 모듈 | `FeatureHomeInterface` → `Domain` ✅ |
| App | Feature 최상위 모듈 | `App` → `Feature` ✅ |
| Implements | 외부 SPM 라이브러리 | `FeatureHome` → `.external(name: "Lottie")` ✅ |

### 4.2 금지되는 의존

| From | To | 이유 |
|------|----|------|
| Implements (A) | 같은 레이어 다른 모듈 Implements (B) | 구현 결합. 컴파일 시간 폭발 ❌ |
| 하위 레이어 | 상위 레이어 | 의존 방향 역전 ❌ |
| Interface | 자기 Implements | 순환 ❌ |
| Interface | 외부 라이브러리 | 재컴파일 영향 폭발 ❌ |
| 어떤 것이든 | Tests | Tests는 leaf ❌ |
| 어떤 것이든 | Example | Example은 leaf ❌ |

### 4.3 검증 방법

```bash
tuist graph
```
그래프를 시각화해 위반이 없는지 확인. 빌드 시 에러는 거의 의존 규칙 위반.

## 5. 네이밍 규칙

### 5.1 모듈/타겟 이름

`<Layer><Module><TargetType>` 형식:

| 예시 | 의미 |
|------|------|
| `FeatureHome` | Feature.Home의 Implements |
| `FeatureHomeInterface` | 〃의 Interface |
| `FeatureHomeTesting` | 〃의 Testing |
| `FeatureHomeTests` | 〃의 단위 테스트 번들 |
| `FeatureHomeExample` | 〃의 데모 앱 |
| `Feature` | Feature 레이어 최상위 (aggregator) |

### 5.2 Bundle ID

`<reverseDomain>.<layer소문자>.<module소문자>.<target소문자>`

예: `com.example.feature.home.interface`

### 5.3 디렉토리

```
Projects/Feature/Home/
├── Project.swift
├── Sources/        ← Implements 소스
├── Interface/      ← Interface 소스
├── Testing/        ← Testing 소스
├── Tests/          ← Tests 소스
└── Example/        ← Example 앱 소스
    └── Resources/  ← Example 앱 리소스
```

### 5.4 enum case

`ModulePath.<Layer>` enum의 case는 **PascalCase**.

```swift
enum Feature: String, CaseIterable {
    case Home
    case Settings
    case Profile
}
```

이름 짓는 원칙:
- 도메인을 드러낼 것 (`Auth`, `Payment` ✅, `iOS Feature` ❌)
- 1~2개 단어로 짧게 (`Onboarding` ✅, `OnboardingScreen` ❌)
- 단수형 권장 (`Setting` ❌, `Settings`은 관용적이라 OK)

## 6. ModulePath enum 관리

### 6.1 파일 위치

`Plugins/DependencyPlugin/ProjectDescriptionHelpers/ModulePath/`

### 6.2 ModulePath.swift (최상위)

```swift
public enum ModulePath {
    case feature(Feature)
    case domain(Domain)
    case core(Core)
    case shared(Shared)
}
```

### 6.3 레이어별 enum 파일

```swift
// ModulePath+Feature.swift
public extension ModulePath {
    enum Feature: String, CaseIterable {
        case Home
        case Onboarding
        case Profile
        case Settings
        
        public static let name: String = "Feature"
    }
}
```

`Domain`, `Core`, `Shared`도 동일 패턴.

### 6.4 enum 변경 룰

| 변경 종류 | 영향 |
|-----------|------|
| case 추가 | 안전. 디렉토리/Project.swift 함께 추가 필수 |
| case 삭제 | 위험. 기존 의존 깨짐. PR 리뷰 필수 |
| case 이름 변경 | 위험. 디렉토리 + Project.swift 모두 수정 필요. 절대 enum만 바꾸지 않음 |

## 7. Target 팩토리 함수 패턴

`Plugins/DependencyPlugin/ProjectDescriptionHelpers/Target+Templates/`에 레이어별 파일.

### 7.1 Target+Feature.swift 패턴

```swift
public extension Target {
    // 레이어 최상위
    static func feature(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Feature.name
        return make(factory: f)
    }
    
    // Interface
    static func feature(interface module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature" + module.rawValue + "Interface"
        f.sources = .interface
        return make(factory: f)
    }
    
    // Implements
    static func feature(implements module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature" + module.rawValue
        return make(factory: f)
    }
    
    // Testing
    static func feature(testing module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature" + module.rawValue + "Testing"
        f.sources = .testing
        return make(factory: f)
    }
    
    // Tests
    static func feature(tests module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature" + module.rawValue + "Tests"
        f.sources = .tests
        f.product = .unitTests
        return make(factory: f)
    }
    
    // Example
    static func feature(example module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature" + module.rawValue + "Example"
        f.sources = .exampleSources
        f.product = .app
        return make(factory: f)
    }
}
```

`Domain`, `Core`, `Shared`도 동일 6 함수 패턴 (총 4 layer × 6 함수 = 24개).

## 8. Workspace.swift

루트의 `Workspace.swift`는 한 줄로 끝난다:

```swift
import ProjectDescription
import DependencyPlugin

let workspace = Workspace(
    name: "<AppName>",
    projects: ["Projects/*"]
)
```

`Projects/` 하위 모든 디렉토리가 자동 포함.

## 9. Build Configuration

- **Debug** / **Release** 두 가지만 사용
- xcconfig 파일은 사용하지 않음 (필요 시 별도 결정)
- 모든 Project / Target이 동일한 Configuration 사용

`Project+Templates`에서:

```swift
public extension Project {
    static func makeModule(name: String, targets: [Target]) -> Project {
        return Project(
            name: name,
            organizationName: "<TBD>",
            settings: .settings(configurations: [
                .debug(name: "Debug"),
                .release(name: "Release"),
            ]),
            targets: targets
        )
    }
}
```

## 10. SwiftUI 사용 규칙

- 모든 View는 SwiftUI 기반. UIKit 사용 시 PR 리뷰 사유 명시
- ViewModel은 `@Observable` (iOS 17+) 또는 `ObservableObject`
- Preview는 모든 View에 권장
- Navigation은 `NavigationStack`

## 11. 새 모듈 추가 워크플로우 (요약)

1. 어느 레이어인지 결정 (§12 기준 참고)
2. `ModulePath+<Layer>.swift`에 case 추가
3. `Projects/<Layer>/<NewModule>/` 디렉토리 + 5개 서브 폴더 생성
4. `Projects/<Layer>/<NewModule>/Project.swift` 작성 (5 target)
5. `Projects/<Layer>/Project.swift` (레이어 최상위)에 `.implements(...)` 추가
6. 더미 Swift 파일 1개씩 추가
7. `tuist generate` → 빌드/테스트 통과 확인

상세 절차는 SKILL.md의 7단계 워크플로우 참조.

## 12. 모듈 분리 기준

새 화면을 만들 때 **새 모듈 vs 기존 모듈에 추가** 판단 기준.

### 새 모듈을 만든다 ✅

- 독립적인 도메인 영역이다 (예: 새 탭, 새 큰 기능)
- 다른 팀/사람이 작업할 가능성이 있다
- 빌드 격리가 필요하다 (단독 데모, 빠른 빌드)
- 재사용 가능성이 있다

### 기존 모듈에 추가한다 ✅

- 기존 기능의 보조 화면이다 (예: Settings 안의 알림 설정)
- 그 모듈에서만 쓰는 컴포넌트다
- 화면이 5개 미만이고 한 도메인으로 묶인다

원칙: **"화면 = 모듈"이 아니라 "도메인 영역 = 모듈"**

## 13. 안티 패턴 (절대 금지)

| 금지 사항 | 이유 |
|-----------|------|
| Implements ↔ Implements 직접 의존 | 컴파일 시간 폭발 |
| 하위 → 상위 레이어 의존 | 의존 방향 역전 |
| Interface가 외부 라이브러리 import | 재컴파일 영향 폭발 |
| 한 모듈에 화면 50개 | 모듈 분리 의미 상실 |
| Project.swift에 직접 Target 작성 (헬퍼 우회) | 일관성 깨짐 |
| enum case 변경 후 디렉토리 변경 안 함 | tuist generate 실패 |
| Tests/Example을 다른 모듈이 의존 | 빌드 그래프 망가짐 |
| 한 Project.swift에 여러 모듈 정의 | Pumping 패턴 위반. 모듈당 Project.swift 1개 |

## 14. 외부 의존성

- 외부 SPM 의존성은 `Tuist/Package.swift`에 정의
- 각 모듈은 `.external(name: "<lib>")`로 import
- **Interface 타겟에는 외부 의존성 추가 절대 금지**
