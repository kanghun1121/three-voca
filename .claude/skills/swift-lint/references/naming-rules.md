# Naming Rules

POSTECH Swift Style Guide의 네이밍 규약. 변수/함수/enum/struct/class/protocol/delegate 7개 카테고리.

## 1. 변수

### 룰
- **lowerCamelCase** 사용
- 배열/복수 의미는 **끝에 `s`** 추가
- Bool 타입은 `is/has/should` 시작 권장 (가이드 명시는 아니지만 일반 컨벤션)

### 예시

**Good ✅**
```swift
var categories: [String]
var person: Person
var isShowing: Bool
```

**Bad ❌**
```swift
var category: [String]      // 배열인데 단수
var show: Bool              // is/has/should 없음
var Person: Person          // PascalCase
```

---

## 2. 함수

### 룰
- **lowerCamelCase**
- 일반적으로 **동사원형**으로 시작
- Event-handling 함수: `will` 또는 `did` + 동사
  - `will`: 행위 직전
  - `did`: 행위 직후
- 데이터 가져오기:
  - `request` — 실패/에러 가능한 비동기 작업 (예: HTTP)
  - `fetch` — 실패하지 않고 즉시 반환하는 작업
  - `get` 사용 지양

### 예시

**Good ✅**
```swift
class AcademyViewController {
    private func didFinishSession() { /* ... */ }
    private func willFinishSession() { /* ... */ }
    private func scheduleDidChange() { /* ... */ }
}

func requestData(for user: User) -> Data?     // 비동기, 실패 가능
func fetchData(for user: User) -> Data         // 즉시 반환
```

**Bad ❌**
```swift
class AcademyViewController {
    private func handleSessionEnd() { /* ... */ }   // handle은 모호
    private func finishSession() { /* ... */ }      // will/did 없음
    private func scheduleChanged() { /* ... */ }    // 동사가 끝에
}

func getData(for user: User) -> Data?              // get 지양
```

### 검토 포인트
- 함수명이 명사로 시작? → 동사로 바꾸기 제안
- `handle*`, `process*` 등 모호한 동사 → 더 구체적인 동사 제안
- Event 핸들러인데 `will/did` 없음 → 추가 제안
- `get*` 발견 → 비동기/실패 여부 보고 `request` 또는 `fetch` 제안

---

## 3. 열거형 (Enum)

### 룰
- 타입 이름: **UpperCamelCase**
- case 이름: **lowerCamelCase**

### 예시

**Good ✅**
```swift
enum Result {
    case success
    case failure
}
```

**Bad ❌**
```swift
enum result {           // 타입이 lowerCamelCase
    case Success        // case가 UpperCamelCase
    case Failure
}
```

---

## 4. 구조체와 클래스

### 룰
- 타입 이름: **UpperCamelCase**
- **prefix 금지** (Swift는 모듈 네임스페이스가 있어서 불필요)
- 프로퍼티/메서드: **lowerCamelCase**

### 예시

**Good ✅**
```swift
struct LeftRectangle {
    var width: Int
    var height: Int

    func drawRectangle() { /* ... */ }
}

class Mentee {
    let id: String
    var group: Int

    func callOutMentor() { /* ... */ }
}
```

**Bad ❌**
```swift
struct rwRightRectangle {       // prefix `rw` 금지
    var Width: Int               // 프로퍼티 PascalCase
    var Height: Int

    func DrawRectangle() { /* ... */ }
}
```

### 검토 포인트
- 타입명에 `XX_`, `rw`, `JT` 같은 prefix 발견 → 제거 제안
- 프로퍼티/메서드 PascalCase → lowerCamelCase 제안

---

## 5. 프로토콜

### 룰
- **구조**(struct-like)를 나타내는 프로토콜 → **명사**
- **능력**(capability)을 나타내는 프로토콜 → **형용사** (-able, -ible)

### 예시

**Good ✅**
```swift
// 구조 — 명사
protocol Car {
    var speed: Int { get set }
    var name: String { get }
    func speedUp(speed: Int) -> Bool
}

// 능력 — 형용사
protocol Drivable {
    func accelerate(speed: Int) -> ()
    func slowDown(speed: Int) -> ()
}
```

**Bad ❌**
```swift
// 구조와 능력이 한 프로토콜에 섞임
protocol Drivable {
    var speed: Int { get set }       // 구조
    var name: String { get }
    func speedUp(speed: Int) -> Bool
    func accelerate(speed: Int) -> () // 능력
    func slowDown(speed: Int) -> ()
}
```

### 검토 포인트
- `-able`, `-ible` 끝나는 프로토콜이 프로퍼티만 가진 경우 → 명사로 변경 제안
- 명사 프로토콜이 동작만 정의하는 경우 → `-able` 제안
- 프로토콜이 너무 큼 → 분리 제안

---

## 6. 델리게이트

### 룰
- **첫 번째 인자는 델리게이트의 소스 객체** (예: `_ scrollView: UIScrollView`)
- 인자 라벨은 첫 인자만 생략 (`_`)
- 함수명은 lowerCamelCase

### 예시

**Good ✅**
```swift
// 소스 객체만 받는 경우
protocol UserScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool
}

// 소스 객체 + 추가 인자
protocol UserTableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplayCell cell: Cell,
        cellForRowAt indexPath: IndexPath
    )
}
```

**Bad ❌**
```swift
protocol UserViewDelegate {
    func didScroll()                         // 소스 객체 없음
    func willDisplay(cell: Cell)             // 첫 인자가 소스 객체가 아님
    func UserScrollView(_ s: UIScrollView)   // UpperCamelCase
}
```

### 검토 포인트
- 델리게이트 메서드의 첫 인자가 소스 객체가 아님 → 추가 제안
- 메서드명에 동사 없음 → 추가 제안
- 함수명 PascalCase (충돌 위험) → lowerCamelCase

---

## 빠른 체크리스트

검토 시 다음을 차례로 확인:

- [ ] 모든 변수가 lowerCamelCase인가?
- [ ] 배열 타입 변수에 `s` 접미사가 있는가?
- [ ] Bool 변수가 `is/has/should/can` 등으로 시작하는가?
- [ ] 모든 함수가 동사로 시작하는가?
- [ ] Event-handling 함수에 `will/did` prefix가 있는가?
- [ ] `get*` 함수가 있는가? → `request`/`fetch`로 제안
- [ ] enum 타입은 UpperCamelCase, case는 lowerCamelCase인가?
- [ ] struct/class에 prefix가 있는가? (있으면 제거)
- [ ] 프로토콜이 구조면 명사, 능력이면 형용사인가?
- [ ] Delegate 메서드의 첫 인자가 소스 객체인가?
