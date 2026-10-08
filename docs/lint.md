# 린트 기준

Swift 코드의 작성 규칙(네이밍·포맷·코드)과 검토 등급, 그리고 이를 검사하는 방법을 정의한다.
SwiftUI 작성 규칙은 [swift-style.md](swift-style.md)가 정의하며, 등급과 검사 방법은 이 문서를 따른다.
신규·수정 코드의 작성 기준이며, 기존 코드가 모두 준수한다는 설명은 아니다.
별도로 “권장” 또는 “지양”이라고 표시한 항목 외에는 필수 작성 규칙이다. 언어 자체의 제약과는 구분한다.
기존 불일치는 자동으로 예외가 되지 않는다. 요청과 무관한 일괄 스타일 변경·API 이름 변경은 하지 않는다.

## 적용 및 검토 등급

- 규칙과 필수·권장 여부는 이 문서와 [swift-style.md](swift-style.md)에서 정의한다. 리뷰 스킬은 다른 기준을 중복 정의하지 않는다.
- P0: 컴파일 오류·실제 순환 참조 등 근거가 확인된 정확성 문제. 스타일 선호나 누수 의심만으로 지정하지 않는다.
- P1: 이 문서의 필수 작성 규칙 위반. 네이밍·줄바꿈·import·불필요한 타입 어노테이션 등이 해당한다.
- P2: “권장”·“지양” 항목의 개선 제안. 필수 위반 건수와 구분한다.
- 판단 근거가 부족하면 미확인 사항으로 남긴다. 기존 패턴의 존재만으로 규칙을 강화하거나 완화하지 않는다.

## 1. 네이밍

- 타입·프로토콜은 UpperCamelCase, 변수·함수·enum case는 lowerCamelCase를 사용한다.
- 컬렉션 이름은 복수 의미를 드러낸다. Bool은 `is` 로 시작하기를 권장한다.
- 함수는 동작을 드러내는 이름을 사용한다. `handle`, `process`처럼 의미가 넓은 이름은 구체화한다.
- 이벤트 핸들러는 `will`/`did`와 동작을 조합한다. `will`은 직전, `did`는 직후를 나타낸다.
- 버튼 탭 등 액션 핸들러는 명사 + 동작 순서로 짓는다. `audioButtonTapped()`(O), `tapAudioButton()`(X).
- 데이터 조회 이름만으로 동기·비동기 또는 실패 가능성을 단정하지 않는다. 계약은 `async`/`throws`로 확인한다.
- 기존 `fetchDetail` 등의 API 이름을 존중한다. `get` 대신 구체적인 조회 동사 사용을 권장한다.
- 타입에 불필요한 조직·개인 식별 prefix를 붙이지 않는다.
- 프로토콜은 역할을 나타내는 명사 또는 능력을 나타내는 `-able`/`-ible` 형태를 사용한다.
- Delegate 메서드는 첫 인자로 소스 객체를 받고 그 인자의 라벨은 생략한다.
- 도메인·Feature 이름은 [아키텍처 용어 사전](architecture.md#용어-사전)을 따른다.

## 2. 포맷

### 2.1 들여쓰기

- 들여쓰기는 스페이스 4개로 통일한다. 탭 문자를 사용하지 않는다.

### 2.2 띄어쓰기

- 타입·딕셔너리의 콜론은 오른쪽에만 한 칸, 콤마 뒤에는 한 칸을 둔다.
- 이항 연산자 양쪽과 여는 중괄호 앞에 공백을 둔다. 함수 호출명과 `(` 사이에는 넣지 않는다.

### 2.3 파라미터 줄바꿈

- 일반 인자가 1~2개면 한 줄, 3개 이상이면 한 줄에 하나씩 작성한다.
- 함수·메서드·이니셜라이저의 선언과 호출에 동일하게 적용한다.
- 여러 줄이면 첫 인자는 `(` 다음 줄, 닫는 `)`는 별도 줄에 둔다.
- 후행 클로저 본문은 별도 블록으로 작성하며, 일반 인자의 줄바꿈과 구분한다.

```swift
func select(id: String, animated: Bool) { }
func load(
    id: String,
    page: Int,
    limit: Int
) { }
```

### 2.4 Import 정렬

- Apple Framework → 내부 Module → Third Party 순서로 그룹을 나눈다.
- 각 그룹은 알파벳 오름차순이며, 그룹 사이에 빈 줄 하나를 둔다. 중복 import는 제거한다.
- 아래는 그룹 구분 예시다. 실제 파일에서는 필요한 모듈만 import한다.

```swift
import Foundation
import SwiftUI

import DesignSystem
import DomainInterface

import Dependencies
import SwiftUINavigation
```

### 2.5 주석

- 주석은 코드가 무엇이고 어떻게 동작하는지만 설명한다. 결정 경위·대안 비교·과거 이력·작업 맥락(왜 이렇게 바꿨는지, 무엇을 시도했는지)은 적지 않는다. 이런 내용은 커밋 메시지와 PR에 남긴다.
- 선언의 사용법을 설명하는 문서 주석은 `///`, 구현의 동작을 보충하는 주석은 `//`를 사용한다.
- 자명한 코드의 동작을 반복 설명하지 않는다. 코드만으로 드러나지 않는 계약·제약·반환 의미·부수 효과를 간결하게 적는다.
- 주석 하나(연속된 주석 줄 묶음)는 공백 포함 150자를 넘기지 않는다. 넘으면 코드 구조나 이름으로 드러내거나 줄인다.
- 영역 구분은 `MARK: -`, 남은 작업·결함 표시는 `TODO:`/`FIXME:` 사용을 권장한다.

```swift
// Bad: 결정 경위
// 처음엔 공유 헬퍼로 뺐다가 호출부가 2곳뿐이라 인라인으로 되돌림.

// Good: 코드에 대한 설명
/// 캐시에 없으면 `nil`을 반환하며 네트워크를 호출하지 않는다.
```

### 2.6 프로퍼티 순서

- 일반 stored property를 먼저, observer가 있는 property와 computed property를 뒤에 둔다.

## 3. 코드

- 마지막 클로저 인자는 후행 클로저로 작성하고, 클로저만 받으면 호출 괄호를 생략한다.
- 다중 후행 클로저는 첫 라벨을 생략하고 이후 클로저의 라벨을 유지한다.
- 클로저 인자의 타입은 문맥에서 명확하면 생략한다.
- 값의 타입이 명확하면 불필요한 타입 어노테이션을 생략한다.
- `CGFloat`, `Int64` 등 의도한 타입이 추론 결과와 다르거나 빈 컬렉션이면 타입을 명시한다.
- 컬렉션 타입은 `[T]`, `[K: V]`를 사용한다. 빈 컬렉션은 `var items: [Item] = []`처럼 쓴다.
- 캡처는 실제 소유 관계·수명을 확인한다. 모든 클로저에 기계적으로 `[weak self]`를 붙이지 않는다.
- 순환 참조는 소유 관계를 조정하거나 `weak`로 끊는다. `unowned`는 대상 수명이 보장될 때만 사용한다.
- `weak` 참조는 Optional이며, delegate가 소유권을 갖지 않아야 할 때는 약한 참조로 선언한다.

## 현재 도구

- 자동 린터는 없다. SwiftLint 미설치, 저장소에 `.swiftlint.yml`·`.swiftformat` 설정 없음.
- `swiftformat`은 개발 머신에 설치돼 있으나 설정이 없어 기준으로 쓰지 않는다.
- CI(`.github/workflows/ci.yml`)는 `tuist test AllTest`만 실행한다. 스타일 위반은 CI를 실패시키지 않는다.
- 사람이 요청할 때 `swift-lint` 스킬이 이 문서와 `swift-style.md` 기준으로 검토한다. 요청 범위 밖 코드는 일괄 수정하지 않는다.

## 검사 방법

저장소 루트에서 실행한다. 대상은 `Projects/**/Sources`이며 `Tests/`와 `Derived/`는 제외한다.

### 기계적으로 확인 가능한 것

| 규칙 | 확인 명령 |
|---|---|
| 탭 들여쓰기 금지 (§2.1) | `grep -rlE $'^\t' Projects --include='*.swift' --exclude-dir=Derived` |
| `try!` 지양 | `grep -rn 'try!' Projects --include='*.swift' --exclude-dir=Tests --exclude-dir=Derived` |
| `print` 대신 로거 사용 | `grep -rnE '^\s*print\(' Projects --include='*.swift' --exclude-dir=Tests --exclude-dir=Derived` |
| `@State` private (swift-style.md) | `grep -rnE '@State (var\|let)' Projects --include='*.swift' --exclude-dir=Derived` |
| `@ViewBuilder` 함수·computed property 지양 (swift-style.md) | `grep -rnE 'var \w+: some View' Projects --include='*.swift' --exclude-dir=Derived` 결과에서 `var body` 제외 |
| 색상은 Figma 토큰 경로를 따르는 `DesignSystemColor` 사용 | `rg -n 'Color\(red:|DesignSystemAsset\.[A-Za-z0-9_]+\.swiftUIColor' Projects --glob '*.swift' --glob '!DesignSystemColor.swift'` |
| App·Feature의 폰트는 DS Typography 사용; 자간·행간 직접 지정 금지 | `rg -n 'swiftUIFont|\.font\(\.system|\.fontWeight\(|\.kerning\(|\.tracking\(|\.lineSpacing\(' Projects/App Projects/Feature --glob '*.swift' --glob '!**/Derived/**'` |

### 코드를 읽어야 확인되는 것

| 규칙 | 이유 |
|---|---|
| View당 레이아웃 컨테이너 1개 (swift-style.md) | 중첩·조건 분기 구조를 봐야 센다 |
| 파라미터 3개 이상 줄바꿈 (§2.3) | 클로저·문자열 안의 콜론과 구분해야 한다 |
| import 그룹·정렬 (§2.4) | 모듈이 Apple인지 내부인지 판단해야 한다. Tuist 매니페스트(`Project.swift`)는 별도 확인 |
| 네이밍·Bool 접두어·액션 핸들러 (§1) | 문맥 의존 |
| 주석에 결정 경위·이력이 없는가 (§2.5) | 문장의 의도를 읽어야 한다 |
| `[weak self]` 적정성 (§3) | 소유 관계를 봐야 한다 |

이 항목은 `swift-lint` 스킬로 검토한다. grep으로 건수만 세어 위반으로 단정하지 않는다.
