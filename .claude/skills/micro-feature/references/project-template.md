# Project.swift Template (Feature)

본 스킬에서 사용하는 Feature 모듈의 Project.swift 템플릿.

## 표준 Feature 모듈 (5 target 모두 포함)

가장 일반적인 케이스. UI 있는 Feature.

**파일 위치**: `Projects/Feature/<MODULE>/Project.swift`

```swift
import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.<MODULE>.rawValue,
    targets: [
        // 1. Interface
        .feature(interface: .<MODULE>, factory: .init(
            dependencies: [
                .domain,
                // .feature(interface: .OtherFeature),  // 다른 Feature 통신 필요 시
            ]
        )),
        
        // 2. Implements
        .feature(implements: .<MODULE>, factory: .init(
            dependencies: [
                .feature(interface: .<MODULE>),
                // .feature(interface: .OtherFeature),  // ⚠️ 같은 레이어는 Interface만!
            ]
        )),
        
        // 3. Testing (선택)
        .feature(testing: .<MODULE>, factory: .init(
            dependencies: [
                .feature(interface: .<MODULE>)
            ]
        )),
        
        // 4. Tests (선택)
        .feature(tests: .<MODULE>, factory: .init(
            dependencies: [
                .feature(testing: .<MODULE>)
            ]
        )),
        
        // 5. Example 앱 (선택)
        .feature(example: .<MODULE>, factory: .init(
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": "1.0",
                "CFBundleVersion": "1",
                "UILaunchStoryboardName": "LaunchScreen",
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": []
                ]
            ]),
            dependencies: [
                .feature(interface: .<MODULE>),
                .feature(implements: .<MODULE>),
            ]
        )),
    ]
)
```

플레이스홀더 `<MODULE>`을 실제 모듈 이름으로 치환한다 (예: `Settings`, `Login`).

## 의존 패턴 모음

### 같은 레이어 다른 Feature 사용 (Interface 통해서만!)

`Profile` Feature가 `Auth` Feature의 기능을 사용해야 할 때:

```swift
.feature(implements: .Profile, factory: .init(
    dependencies: [
        .feature(interface: .Profile),       // 자기 Interface
        .feature(interface: .Auth),          // ✅ 다른 Feature는 Interface만
        // .feature(implements: .Auth),      // ❌ 절대 금지
    ]
))
```

### 하위 레이어 사용

```swift
.feature(implements: .Settings, factory: .init(
    dependencies: [
        .feature(interface: .Settings),
        .domain,                               // ✅ Domain 최상위 (모든 Domain 모듈 따라옴)
        // .domain(interface: .User),          // 더 좁게 가져오고 싶을 때
    ]
))
```

### 외부 SPM 라이브러리 사용

```swift
.feature(implements: .Login, factory: .init(
    dependencies: [
        .feature(interface: .Login),
        .external(name: "Lottie"),             // ✅ Implements에서만!
    ]
))
```

⚠️ Interface 타겟에 `.external` 추가 ❌ 절대 금지 (재컴파일 폭발)

### Resources 포함 (이미지, asset 등)

```swift
.feature(implements: .Settings, factory: .init(
    resources: ["Resources/**"],
    dependencies: [
        .feature(interface: .Settings),
    ]
))
```

## 타겟 일부 생략 케이스

스킬의 단계 1에서 결정한 옵션에 따라 타겟을 빼고 작성한다.

### Example 없는 Feature (드물게)

```swift
let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.<MODULE>.rawValue,
    targets: [
        .feature(interface: .<MODULE>, factory: .init(
            dependencies: [.domain]
        )),
        .feature(implements: .<MODULE>, factory: .init(
            dependencies: [.feature(interface: .<MODULE>)]
        )),
        .feature(testing: .<MODULE>, factory: .init(
            dependencies: [.feature(interface: .<MODULE>)]
        )),
        .feature(tests: .<MODULE>, factory: .init(
            dependencies: [.feature(testing: .<MODULE>)]
        )),
        // Example 생략
    ]
)
```

### Testing 없는 Feature (mock 불필요한 경우)

```swift
let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.<MODULE>.rawValue,
    targets: [
        .feature(interface: .<MODULE>, factory: .init(
            dependencies: [.domain]
        )),
        .feature(implements: .<MODULE>, factory: .init(
            dependencies: [.feature(interface: .<MODULE>)]
        )),
        // Testing 생략
        .feature(tests: .<MODULE>, factory: .init(
            dependencies: [
                // Testing 없으면 자기 Implements만 의존
            ]
        )),
        .feature(example: .<MODULE>, factory: .init(
            infoPlist: .extendingDefault(with: [/* ... */]),
            dependencies: [
                .feature(interface: .<MODULE>),
                .feature(implements: .<MODULE>),
            ]
        )),
    ]
)
```

## Feature 레이어 최상위 (Aggregator) Project.swift

스킬의 단계 6에서 업데이트하는 파일.

**파일 위치**: `Projects/Feature/Project.swift`

```swift
import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let targets: [Target] = [
    .feature(factory: .init(
        dependencies: [
            .domain,                          // 다음 레이어 최상위
            // 모든 하위 Feature의 Implements (알파벳 순서 권장)
            .feature(implements: .Home),
            .feature(implements: .Onboarding),
            .feature(implements: .Profile),
            .feature(implements: .Settings),
            // 새 Feature 추가 시 여기에 한 줄 추가
        ]
    ))
]

let project = Project.makeModule(name: "Feature", targets: targets)
```

**중요**: 새 Feature 추가 후 이 파일 업데이트를 잊으면 App에서 새 Feature를 사용할 수 없다.

## 디렉토리 ↔ 타겟 매핑

각 타겟의 `sources` 파라미터는 헬퍼에서 자동으로 디렉토리를 결정한다.

| 타겟 타입 | 디렉토리 | 헬퍼 sources 값 |
|----------|---------|----------------|
| Interface | `Interface/` | `.interface` |
| Implements | `Sources/` | `.sources` (기본값) |
| Testing | `Testing/` | `.testing` |
| Tests | `Tests/` | `.tests` |
| Example | `Example/` | `.exampleSources` |

각 디렉토리는 `**` 글롭으로 모든 하위 Swift 파일을 자동 포함.

## 작성 후 자가 검증 체크리스트

저장 전 다음을 확인한다:

- [ ] `name`이 `Feature<MODULE>` 형식 (예: `FeatureSettings`)
- [ ] `Project.makeModule(...)` 호출
- [ ] Implements 의존이 자기 Interface 포함
- [ ] 같은 레이어 다른 모듈 의존이 `interface:`로만 사용 (`implements:` ❌)
- [ ] 하위 레이어 의존은 `.domain` 같은 최상위 모듈만 사용
- [ ] Example의 `infoPlist`가 들어 있음 (Example 만든 경우)
- [ ] Tests가 자기 Testing 또는 자기 Implements를 의존
- [ ] 단계 1에서 만들지 않기로 한 타겟이 템플릿에서 제거됨
- [ ] 외부 라이브러리(`.external`)가 Interface 타겟에 ❌

## Domain/Core/Shared 모듈은?

본 템플릿은 Feature 전용이다. Domain/Core/Shared 모듈은 동일 패턴이지만:

- 헬퍼 함수가 `.domain(...)`, `.core(...)`, `.shared(...)`
- 디렉토리가 `Projects/Domain/<Module>/` 등
- 의존 가능 대상이 다름 (architecture-rules.md §4)

상세는 `references/architecture-rules.md` 참조.
