---
name: micro-feature
description: Tuist MicroFeature 아키텍처를 따르는 iOS 프로젝트(Feature/Domain/Core/Shared 4-layer + Interface/Implements/Testing/Tests/Example 5-target type, Pumping-iOS 패턴)에 새 Feature 모듈을 추가하거나 스캐폴드할 때 반드시 이 스킬을 사용한다. 사용자가 '로그인 화면 추가해줘', 'Settings Feature 만들어줘', 'Onboarding 새로 추가', '결제 기능 모듈', '홈 화면 만들어', 'add a chat feature', 'create a new screen module', 'scaffold a feature' 같이 새 기능/화면/모듈 생성을 요청하면 — Tuist/MicroFeature/모듈이라는 단어를 명시하지 않더라도 — 무조건 트리거한다. ModulePath enum 수정, Projects/Feature/<Module>/ 디렉토리 생성, 5개 타겟(Interface/Implements/Testing/Tests/Example)이 정의된 Project.swift 작성, 레이어 최상위 aggregator Project.swift 업데이트, 더미 소스 + tuist generate까지 일관되게 처리한다. 단, 최초 프로젝트 부트스트랩(Workspace/DependencyPlugin/Projects 자체 셋업)이나 기존 Feature 모듈 내부에 화면 1개만 추가하는 경우는 이 스킬의 범위가 아니다.
---

# micro-feature

Pumping-iOS 패턴을 따르는 Tuist 프로젝트에 새 Feature 모듈을 추가하는 스킬.

작업을 시작하기 전, **반드시** 다음 참조 파일을 먼저 읽는다:

| 파일 | 언제 읽는가 |
|------|------------|
| `references/architecture-rules.md` | 작업 시작 전 항상 |
| `references/project-template.md` | 단계 5 (Project.swift 작성) |
| `references/dummy-code.md` | 단계 7 (더미 소스 작성) |

---

## 절대 어기지 않는 3가지 원칙

`references/architecture-rules.md`의 원칙을 다시 명시:

1. **모듈 = 도메인 영역**. 화면 1개당 모듈 1개가 아니다.
2. **상위 → 하위 레이어로만 의존**. 역방향 절대 금지.
3. **같은 레이어 내에서는 Interface로만 통신**. Implements ↔ Implements 직접 의존 절대 금지.

이 원칙을 위반할 가능성이 있으면 작업 중단하고 사용자에게 확인한다.

---

## 트리거 케이스 vs 비-트리거 케이스

### ✅ 이 스킬을 사용한다

- "Settings Feature 추가해줘"
- "로그인 화면 만들어줘"
- "Onboarding 새로 추가"
- "결제 기능 모듈 추가"
- "홈 화면 만들어"
- "create a new feature for chat"
- "scaffold an Auth feature"
- "add a profile screen module"

### ❌ 이 스킬을 사용하지 않는다

- "Tuist 처음 세팅해줘" → 최초 부트스트랩. 별도 작업.
- "Settings 안에 알림 설정 화면 추가" → 기존 Feature 내부 화면 추가. 그냥 파일 추가.
- "Domain/Auth 모듈 추가" → Domain 레이어. 본 스킬은 Feature 전용.
- "외부 SPM 패키지 추가" → 의존성 관리. Project.swift 수정만.
- "빌드 설정 변경" → Configuration 작업.

Domain/Core/Shared 레이어 모듈 요청이 들어오면 사용자에게 알리고, 동일 패턴이지만 본 스킬은 Feature 전용임을 안내한다.

---

## 작업 워크플로우 (7단계)

총 7단계. 각 단계 종료 시 사용자에게 짧게 보고한다.

### 단계 1 — 의도 명확화

다음 5가지를 결정한다. 모호하면 사용자에게 **단 한 번** 묻는다:

| 항목 | 결정 방법 |
|------|----------|
| 모듈 이름 | 사용자 요청에서 추출. PascalCase. `로그인` → `Login`, `결제` → `Payment` |
| Example 앱 필요 여부 | UI 있으면 기본 Yes. 사용자가 명시하면 따름 |
| Testing 타겟 필요 여부 | 다른 모듈이 mock으로 쓸 가능성 있으면 Yes. 일반적으로 Yes |
| Tests 타겟 필요 여부 | 거의 항상 Yes |
| 같은 레이어 다른 Feature 의존 | 사용자 요청에서 추론. 없으면 빈 리스트 |

#### 새 모듈을 만들지 말아야 할 신호

다음이 보이면 **작업 시작 전** 사용자에게 확인한다:

- 요청 화면이 기존 Feature의 보조 화면 (예: "Settings 안에 알림 설정")
- 화면 1개만을 위한 모듈
- 비슷한 이름의 Feature가 이미 존재 (`Login` 요청인데 `Auth`가 있음)

이 경우 "기존 X Feature에 화면을 추가하는 게 더 적절해 보입니다. 그래도 새 모듈로 만들까요?"라고 제안한다.

### 단계 2 — 사전 점검

```bash
# 프로젝트 루트인지 확인
ls Workspace.swift Plugins/DependencyPlugin/ Projects/Feature/ 2>/dev/null
```

위 3개가 모두 있어야 한다. 하나라도 없으면 "이 스킬은 기존 Tuist 프로젝트 셋업을 가정합니다. 먼저 프로젝트 부트스트랩이 필요합니다."라고 알리고 중단한다.

이어서 enum 파일을 읽어 case 중복 확인:

```bash
cat Plugins/DependencyPlugin/ProjectDescriptionHelpers/ModulePath/ModulePath+Feature.swift
```

같은 이름 case가 이미 있으면 중단하고 사용자에게 알린다.

### 단계 3 — ModulePath enum에 case 추가

대상 파일을 읽어 알파벳 순서로 case를 삽입한다.

**파일**: `Plugins/DependencyPlugin/ProjectDescriptionHelpers/ModulePath/ModulePath+Feature.swift`

**예시**: `Settings` 추가:
```swift
public extension ModulePath {
    enum Feature: String, CaseIterable {
        case Home
        case Onboarding
        case Profile
        case Settings  // ← 추가
        
        public static let name: String = "Feature"
    }
}
```

### 단계 4 — 디렉토리 구조 생성

```bash
MODULE="Settings"          # 모듈 이름
BASE="Projects/Feature/${MODULE}"

mkdir -p "${BASE}/Sources"
mkdir -p "${BASE}/Interface"
mkdir -p "${BASE}/Tests"

# 단계 1에서 결정한 옵션
mkdir -p "${BASE}/Testing"      # Testing 타겟 만들 때
mkdir -p "${BASE}/Example"      # Example 타겟 만들 때
mkdir -p "${BASE}/Example/Resources"   # Example가 있으면 LaunchScreen 위치
```

### 단계 5 — Project.swift 작성

`references/project-template.md`의 표준 템플릿을 사용한다.
플레이스홀더(`<MODULE>`)를 모듈 이름으로 치환한다.

**저장 전 체크리스트**:
- [ ] `name`이 `Feature<MODULE>` 형식 (예: `FeatureSettings`)
- [ ] 같은 레이어 다른 모듈 의존이 `interface:`로만 사용 (`implements:` ❌)
- [ ] 하위 레이어 의존은 `.domain` 같은 최상위 모듈만 사용
- [ ] 단계 1에서 만들지 않기로 한 타겟은 템플릿에서 제거

### 단계 6 — Feature 레이어 최상위 Project.swift 업데이트

**파일**: `Projects/Feature/Project.swift`

dependencies 배열에 `.feature(implements: .<MODULE>)`를 알파벳 순서로 추가:

```swift
let targets: [Target] = [
    .feature(factory: .init(
        dependencies: [
            .domain,
            .feature(implements: .Home),
            .feature(implements: .Onboarding),
            .feature(implements: .Profile),
            .feature(implements: .Settings),  // ← 추가
        ]
    ))
]
```

### 단계 7 — 더미 소스 + 빌드 검증

`references/dummy-code.md`의 템플릿을 사용해 각 폴더에 최소 Swift 파일 1개씩 생성한다.

생성할 파일 목록:
- `Interface/<MODULE>Interface.swift`
- `Sources/<MODULE>.swift`
- `Testing/<MODULE>Mock.swift` (Testing 있을 때)
- `Tests/<MODULE>Tests.swift` (Tests 있을 때)
- `Example/<MODULE>ExampleApp.swift` (Example 있을 때)
- `Example/Resources/LaunchScreen.storyboard` (Example 있을 때)

이어서 generate:

```bash
tuist generate
```

#### 성공 시 보고

사용자에게 다음을 알린다:
- 추가된 enum case
- 생성된 디렉토리/파일 목록
- 새로 사용 가능한 Scheme 이름들 (`Feature<MODULE>`, `Feature<MODULE>Interface`, `Feature<MODULE>Example` 등)
- 다음 권장 작업: "이제 `<MODULE>Interface.swift`에 public API를 정의하세요"

#### 실패 시 대응

- 에러 메시지를 사용자에게 그대로 보여준다
- 가장 흔한 원인: 의존 규칙 위반 (`references/architecture-rules.md` §의존규칙 재확인)
- 그다음 흔한 원인: enum case 누락, 디렉토리/파일명 불일치
- 가능하면 가설 1~2개 제시하고 사용자가 선택하게 한다

---

## 자주 빠지는 함정

| 함정 | 방지법 |
|------|--------|
| enum case만 추가하고 디렉토리 안 만듦 | 단계 4 절대 건너뛰지 않기 |
| 레이어 최상위 Project.swift 업데이트 누락 | 단계 6 절대 건너뛰지 않기 |
| Interface 타겟이 외부 라이브러리 import | Interface는 깨끗하게. 외부 의존은 Implements로 |
| Implements가 다른 모듈 Implements를 import | 같은 레이어는 Interface로만! |
| Tests/Example을 다른 모듈이 의존 | Tests/Example은 항상 leaf |
| 모듈 이름에 소문자/공백/언더스코어 포함 | PascalCase 강제. `login_screen` ❌, `Login` ✅ |
| `iOS Feature` 같은 모호한 이름 | 도메인을 드러내는 이름 사용 (`Auth`, `Payment`, `Onboarding`) |

---

## 사용 예시

### 예시 1 — 단순 Feature 추가

**사용자**: "Settings Feature 추가해줘"

스킬 동작:
1. 추론: 이름=Settings, Example=Yes, Testing=Yes, Tests=Yes, 의존=없음. 사용자 확인 없이 진행.
2. 프로젝트 점검 → 통과.
3. enum에 `case Settings` 추가.
4. `Projects/Feature/Settings/{Sources,Interface,Testing,Tests,Example}` 생성.
5. Project.swift 작성 — 의존: `[.domain]` (Implements는 자기 Interface).
6. Feature 최상위 Project.swift에 `.feature(implements: .Settings)` 추가.
7. 더미 파일 생성 → `tuist generate` → 결과 보고.

### 예시 2 — 다른 Feature와 통신해야 하는 Feature

**사용자**: "Profile Feature 추가. Auth Feature를 사용해야 함"

스킬 동작:
1. 추론: 이름=Profile, 의존=Auth Feature.
2. 사전 점검에서 Auth Feature가 있는지 확인. 없으면 사용자에게 알림.
3. enum에 `case Profile` 추가.
4. 디렉토리 생성.
5. Project.swift에서:
   - Interface 의존: `[.domain, .feature(interface: .Auth)]`
   - Implements 의존: `[.feature(interface: .Profile), .feature(interface: .Auth)]` ← Implements 아님!
6. Feature 최상위 업데이트.
7. 더미 + generate.

### 예시 3 — 모호한 요청

**사용자**: "토큰 관리하는 거 만들어줘"

스킬 동작:
1. 레이어/이름 모두 모호. 사용자에게 1번 질문:
   ```
   토큰 관리는 보통 다음 중 하나에 위치합니다:
   - Domain/Auth (인증 비즈니스 로직)
   - Core/TokenStorage (저장 인프라)
   - Feature/Login (화면 로직)
   
   본 스킬은 Feature 레이어 전용이라 Feature 화면 모듈로 만든다면 어떤 이름이 좋을까요?
   (예: Feature/Login, Feature/AuthFlow)
   ```
2. 답변 후 표준 절차 진행. 만약 Domain/Core가 적절하다고 판단되면 본 스킬 범위 밖임을 안내.

---

## 참고: Domain/Core/Shared 모듈 요청 시

본 스킬은 Feature 전용이지만, 사용자가 Domain/Core/Shared 모듈을 요청해도 동일 패턴이 적용된다.
다음을 안내하고 작업을 진행할지 묻는다:

```
본 스킬은 Feature 레이어 전용입니다. 
Domain/Core/Shared 모듈도 동일 5-target 패턴을 따르지만, 
의존 규칙과 디렉토리 위치가 다릅니다.

`references/architecture-rules.md`의 §4 의존 규칙과 §1 디렉토리 구조를 
참고하여 동일 절차로 진행할 수 있습니다. 진행할까요?
```

진행 시 단계 1~7을 적용하되 다음만 변경:
- `Plugins/.../ModulePath+<Layer>.swift` 수정 (Domain/Core/Shared)
- `Projects/<Layer>/<Module>/` 디렉토리
- Target 팩토리 호출: `.domain(...)`, `.core(...)`, `.shared(...)`
- 레이어별 의존 규칙은 `references/architecture-rules.md` §4 참조.

---

## 의문이 들면

`references/architecture-rules.md` 다시 읽기. 특히:
- §3 핵심 원칙
- §4 의존 규칙 (가장 중요)
- §12 모듈 분리 기준

그래도 모호하면 사용자에게 묻는다 — 잘못된 모듈 추가는 되돌리기 매우 어렵다.