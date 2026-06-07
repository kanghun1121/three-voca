# Format Rules

들여쓰기, 띄어쓰기, 파라미터 줄바꿈, import 정렬, 주석.

본 카테고리에는 **사용자 커스텀 룰 2개**가 포함된다 (§3 파라미터 줄바꿈, §4 Import 정렬).

## 1. 들여쓰기

### 룰
- **스페이스 4개 = 탭 1개**
- 한 단계 들여쓰기 = 4 스페이스

### 예시

**Good ✅**
```swift
func sayHiLeeo(isHappy: Bool) {
    if isHappy {
        print("Hi Leeo!")
    }
}
```

**Bad ❌**
```swift
func sayHiLeeo(isHappy: Bool) {
  if isHappy {           // 2 스페이스
    print("Hi Leeo!")
  }
}
```

### 검토 포인트
- 2-space 들여쓰기 발견 → 4-space로 수정 제안
- 탭(`\t`) 문자 발견 → 스페이스로 변경 제안

---

## 2. 띄어쓰기

### 룰
- **콜론(`:`) 오른쪽**에만 한 칸 공백, 왼쪽은 공백 없음

### 예시

**Good ✅**
```swift
let leeo: HappyLeeo
var dict: [String: Int]
func foo(name: String) -> Bool
```

**Bad ❌**
```swift
let leeo : HappyLeeo        // 콜론 왼쪽 공백
let leeo:HappyLeeo          // 콜론 오른쪽 공백 없음
var dict: [String:Int]      // 딕셔너리 콜론도 동일 룰
```

### 추가 띄어쓰기 룰 (일반 컨벤션, 가이드 명시는 아니지만 적용)
- 연산자 양쪽: `a + b`, `x = 1` (✅ 공백 양쪽)
- 콤마 뒤: `func foo(a: Int, b: Int)` (✅ 공백 오른쪽만)
- 중괄호 앞: `func foo() {` (✅ 공백)
- 함수 호출 괄호 앞: `foo()` (❌ 공백 없음)

---

## 3. 파라미터 줄바꿈 ⭐ 사용자 커스텀 룰

### 룰
- **파라미터가 1~2개**: 한 줄에 작성
- **파라미터가 3개 이상**: 한 줄에 하나씩, 첫 줄 비우고 시작, 닫는 괄호는 새 줄

### 적용 범위
- 함수/메서드 선언
- 함수/메서드 호출
- 이니셜라이저 (호출 + 선언)
- struct/class 멤버 호출

### 예시

#### 함수 선언

**Good ✅** — 1~2개는 한 줄
```swift
func add(a: Int, b: Int) -> Int { return a + b }
func toggle(_ flag: Bool) { /* ... */ }
```

**Good ✅** — 3개 이상은 줄바꿈
```swift
func calculate(
    width: Int,
    height: Int,
    depth: Int
) -> Int {
    return width * height * depth
}

func loadUser(
    id: String,
    name: String,
    email: String,
    onSuccess: @escaping (User) -> Void
) { /* ... */ }
```

**Bad ❌**
```swift
// 3개 이상인데 한 줄 (가독성 ↓)
func calculate(width: Int, height: Int, depth: Int) -> Int { /* ... */ }

// 2개인데 줄바꿈 (불필요)
func add(
    a: Int,
    b: Int
) -> Int { return a + b }
```

#### 함수 호출

**Good ✅** — 1~2개는 한 줄
```swift
let result = add(a: 1, b: 2)
let user = User(name: "Leeo")
```

**Good ✅** — 3개 이상은 줄바꿈
```swift
let result = calculate(
    width: 100,
    height: 200,
    depth: 50
)

loadUser(
    id: "u1",
    name: "Leeo",
    email: "leeo@example.com",
    onSuccess: { user in
        print(user)
    }
)
```

**Bad ❌**
```swift
// 3개 이상인데 한 줄
let result = calculate(width: 100, height: 200, depth: 50)
```

#### 이니셜라이저

**Good ✅**
```swift
// 2개 — 한 줄
let point = CGPoint(x: 0, y: 0)

// 4개 — 줄바꿈
let frame = CGRect(
    x: 0,
    y: 0,
    width: 100,
    height: 100
)
```

#### 다중 후행 클로저는 별도

후행 클로저가 다중일 때는 본 룰과 별개로 클로저 룰을 따른다 (`code-rules.md` §클로저 참조).

```swift
// 클로저는 후행으로 빼고, 일반 인자가 3개 이상이면 그 부분만 줄바꿈
loadUser(
    id: "u1",
    name: "Leeo",
    email: "leeo@example.com"
) { user in
    print(user)
} onError: { error in
    print(error)
}
```

### 검토 포인트
- 함수 선언/호출에서 파라미터 카운트 → 3개 이상이면 줄바꿈 위치 확인
- 닫는 괄호가 마지막 인자와 같은 줄에 있음 → 새 줄로 이동 제안
- 2개인데 줄바꿈됨 → 한 줄로 합치기 제안 (선호 사항이므로 P2)

---

## 4. Import 정렬 ⭐ 사용자 커스텀 (강조)

### 룰
- **그룹 순서**: Apple Framework → Module → Third Party (3그룹 고정)
- **각 그룹 내**: 알파벳 오름차순
- **중복 제거**
- **그룹 사이 빈 줄 1개**

#### 그룹 분류 기준

| 그룹 | 포함되는 것 | 예시 |
|------|-----------|------|
| **Apple Framework** | Apple이 제공하는 모든 프레임워크 | `Foundation`, `UIKit`, `SwiftUI`, `Combine`, `CoreData` |
| **Module** | 이 프로젝트 내부 모듈 | `DomainAuth`, `FeatureHome`, `SharedUI` |
| **Third Party** | 외부 라이브러리 (SPM/CocoaPods) | `Alamofire`, `SnapKit`, `ComposableArchitecture` |

### 예시

**Good ✅**
```swift
import Foundation
import SwiftUI
import UIKit

import DomainAuth
import FeatureHomeInterface

import Alamofire
import SnapKit
```

**Good ✅** — Apple Framework만 있는 경우
```swift
import Combine
import Foundation
import SwiftUI
```

**Bad ❌** — 그룹 순서 위반 (Third Party가 Module 앞에 옴)
```swift
import Foundation
import SwiftUI

import Alamofire       // Third Party가 Module보다 먼저 → 위반
import SnapKit

import DomainAuth
import FeatureHomeInterface
```

**Bad ❌** — 정렬 안 됨 / 중복 / 키워드 오타
```swift
import UIKit
import Foundation      // 알파벳 역순 → 위반

importFoundation       // 띄어쓰기 누락
import Alamofire       // 중복
```

### 검토 포인트
- 그룹 순서(Apple → Module → Third Party) 위반 → P1로 재정렬 제안
- 각 그룹 내 알파벳 순서 위반 → P1로 재정렬 제안
- 그룹 사이 빈 줄 없거나 2개 이상 → P1로 수정 제안
- 중복 import → P0으로 제거
- `import` 키워드 뒤 공백 누락 → P0으로 수정 (`importFoundation` ❌)

---

## 5. 주석

### 룰
- 간결하게, 핵심만
- 함수/메서드 doc comment는 `///`로 시작
- 무엇을 하는지, 무엇을 반환하는지 설명
- void/non-nullable 반환은 명시 생략 가능
- `MARK: -` 으로 코드 영역 구분
- `TODO:`, `FIXME:` 사용 권장

### 예시

#### 함수 doc comment

**Good ✅**
```swift
/// 사용자 데이터를 추가합니다.
/// - Parameter name: user fullname
/// - Parameter age: user age
func addData(name: String, age: Int) {
    // ...
}

/// DB내 사용자 이름과 ID로 나이를 조회합니다.
/// - Parameter ID: user ID
/// - Parameter name: user fullname
/// - Returns: user age
func readData(ID: Int, name: String) -> Int {
    var age: Int
    // ...
    return age
}
```

**Bad ❌**
```swift
// 사용자 데이터 추가          // // 주석 (퀵헬프 안 뜸)
func addData(name: String, age: Int) {
    // return void
}
```

#### MARK / TODO / FIXME

```swift
// MARK: - Gryffindor
let password = "Fortuna Major"

// MARK: - Slytherin
class Slytherin { /* ... */ }

// FIXME: - 버그 수정 필요
public func buggyFunc() { /* ... */ }

// TODO: - 문자열 인코딩 함수 작업 계획
private func todoFunc() { /* ... */ }
```

### 검토 포인트
- 함수에 `//` 주석 사용 → `///`로 변경 제안
- 함수 doc에 `- Parameter`, `- Returns` 누락 → 추가 제안 (있으면 좋음, P2)
- 큰 코드 블록인데 MARK 없음 → MARK 추가 제안 (P2)
- TODO/FIXME 표기는 좋은 신호. 위반 아님

---

## 6. 파일 관리 보조 룰 (네이밍/import 외)

POSTECH 가이드 §파일관리 중 import 외 룰:

### Computed properties / property observers 위치

**Good ✅**
```swift
class Earth {
    // 1. stored properties 먼저
    var gravity: CGFloat
    var population: Int
    
    // 2. computed properties / property observer가 있는 properties는 끝에
    var atmosphere: Atmosphere {
        didSet {
            print("oh my god, the atmosphere changed")
        }
    }
    var habitable: Bool {
        return gravity > 0 && atmosphere != .none
    }
}
```

**Bad ❌**
```swift
class Earth {
    var atmosphere: Atmosphere {
        didSet { /* ... */ }
    }
    var gravity: CGFloat        // observer 가진 property 다음에 stored
    var population: Int
}
```

### 검토 포인트
- stored property가 computed/observer 다음에 옴 → 순서 변경 제안

---

## 빠른 체크리스트

- [ ] 들여쓰기가 4 스페이스인가? 탭 문자는 없는가?
- [ ] 콜론 왼쪽 공백 없고, 오른쪽 공백 한 칸인가?
- [ ] 함수 파라미터 1~2개는 한 줄인가?
- [ ] 함수 파라미터 3개 이상은 한 줄에 하나씩 줄바꿈됐는가?
- [ ] 함수 호출도 같은 룰 적용됐는가?
- [ ] Import 그룹 순서가 Apple Framework → Module → Third Party인가?
- [ ] 각 그룹 내 Import가 알파벳 오름차순인가?
- [ ] 그룹 사이 빈 줄이 정확히 1개인가?
- [ ] Import에 중복은 없는가?
- [ ] 함수 doc comment가 `///`인가?
- [ ] Stored property가 computed/observer property보다 먼저 오는가?
