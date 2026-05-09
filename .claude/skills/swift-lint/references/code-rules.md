# Code Rules

클로저, 타입 추론/어노테이션, 메모리 관리.

## 1. 클로저

### 1.1 후행 클로저 축약 (단일 클로저)

#### 룰
단일 후행 클로저인 경우:
- **타입 유추** 사용 (인자 타입 명시 ❌)
- **함수 라벨 생략**
- **소괄호 생략**

#### 예시

**대상 함수**:
```swift
func someFunctionThatTakesAClosure(closure: (Int) -> Void) {
    // body
}
```

**Good ✅**
```swift
someFunctionThatTakesAClosure { int in
    // ...
}
```

**Bad ❌**
```swift
someFunctionThatTakesAClosure(closure: { (arguInt: Int) -> Void in
    // ...
})

someFunctionThatTakesAClosure(closure: { int in
    // ...
})
```

### 1.2 다중 후행 클로저

#### 룰
함수가 클로저들만 인자로 받는 경우:
- 함수 호출 시 **소괄호 생략**
- 첫 번째 인자 라벨 생략
- 인자 사이 콤마 생략

#### 예시

**대상 함수**:
```swift
func doSomething(
    do: (String) -> Void,
    onSuccess: (Any) -> Void,
    onFailure: (Error) -> Void
) { /* ... */ }
```

**Good ✅**
```swift
doSomething { something in
    // do
} onSuccess: { result in
    // success
} onFailure: { error in
    // failure
}
```

**Bad ❌**
```swift
doSomething(do: { something in
    // ...
}, onSuccess: { result in
    // ...
}, onFailure: { error in
    // ...
})
```

### 검토 포인트
- 단일 후행 클로저인데 소괄호/라벨 사용 → 축약 제안
- 인자 타입을 명시함 → 타입 유추 제안
- 다중 후행 클로저인데 콤마/괄호 사용 → 다중 축약 제안

---

## 2. 타입 추론

### 룰
- **컴파일러가 추론할 수 있으면 타입 어노테이션 생략**
- 단, 다음은 명시:
  - `CGFloat`, `Int64` 같이 추론이 부정확할 수 있는 경우
  - 빈 컬렉션 (`[]`, `[:]`)

### 예시

**Good ✅**
```swift
let apple = "Developer"           // String 추론
let book1 = Book()                // Book 추론
let age = 25                      // Int 추론
let frameWidth: CGFloat = 120     // CGFloat 명시 (Int로 추론되면 안 되므로)
```

**Bad ❌**
```swift
let apple: String = "Developer"   // String 명백한데 어노테이션
let book1: Book = Book()          // 좌변 Book = 우변 Book()
let age: Int = 25                 // Int 명백한데 어노테이션
```

### 검토 포인트
- 우변에서 타입이 명백한데 좌변에 타입 어노테이션 → 제거 제안 (P2)
- `CGFloat`, `Int64`, `UInt8` 등을 추론으로 두면 안 되는 경우 → 명시 제안

---

## 3. 타입 어노테이션 (단축 구문)

### 룰
- `Array<T>` 대신 **`[T]`**
- `Dictionary<K, V>` 대신 **`[K: V]`**
- 빈 배열/딕셔너리 선언 시 **타입을 명시**하는 형태 선호

### 예시

**Good ✅**
```swift
var students: [String]?
var student: [String: String]?

// 빈 컬렉션 — 타입 명시
var students: [String] = []
var student: [String: String] = [:]
```

**Bad ❌**
```swift
var students: Array<String>?           // 전체 구문
var student: Dictionary<String, String>?

// 빈 컬렉션 — 우변에 타입 명시
var students = [String]()
var student = [String: String]()
```

### 검토 포인트
- `Array<T>`, `Dictionary<K,V>` 발견 → 단축 구문 제안
- `var x = [T]()` 형태 → `var x: [T] = []` 제안 (P2)

---

## 4. 메모리 관리

### 룰
- 순환 참조 방지 — `weak`, `unowned` 활용
- **`weak` 변수는 반드시 Optional**
- `unowned`는 절대 nil이 되지 않을 것이 확실할 때만

### 예시

**Good ✅**
```swift
class ExampleClass {
    weak var example: ExampleClass? = nil    // weak는 Optional ✅

    init() { print("init class") }
    deinit { print("deinit class") }
}

// 캡처 리스트
let action = { [weak self] in
    self?.doSomething()
}
```

**Bad ❌**
```swift
class ExampleClass {
    weak var example: ExampleClass = nil     // weak가 non-Optional ❌
    
    // 강한 참조 사이클 가능성
    var parent: ExampleClass?
    var child: ExampleClass?                  // 한쪽은 weak여야 함
}
```

### 클로저 캡처 리스트 검토

다음 패턴은 retain cycle 의심:

```swift
// 의심스러움 — self 캡처
class ViewModel {
    var subscription: AnyCancellable?
    
    func bind() {
        subscription = publisher.sink { value in
            self.process(value)         // self 강한 캡처
        }
    }
}

// 수정안
subscription = publisher.sink { [weak self] value in
    self?.process(value)
}
```

### 검토 포인트
- `weak` 변수가 non-Optional → Optional로 변경 제안 (P0)
- 클래스 내부 클로저에서 `self.xxx` 직접 사용 → `[weak self]` 캡처 검토 (P1)
- 부모-자식 관계 양쪽이 모두 강한 참조 → 한쪽 weak 제안 (P0)
- delegate 프로퍼티가 strong → weak 권장 (P0, 메모리 누수 흔한 원인)

---

## 빠른 체크리스트

- [ ] 단일 후행 클로저가 축약되어 있는가? (소괄호/라벨 없음)
- [ ] 다중 후행 클로저가 첫 라벨 + 콤마 없이 호출되는가?
- [ ] 클로저 인자 타입을 불필요하게 명시하지 않는가?
- [ ] 명백한 타입에 어노테이션을 달지 않았는가?
- [ ] CGFloat/Int64 같은 명시 필요 케이스에 어노테이션이 있는가?
- [ ] `Array<T>` / `Dictionary<K,V>` 대신 `[T]` / `[K:V]`를 쓰는가?
- [ ] 빈 컬렉션을 `var x: [T] = []` 형태로 선언하는가?
- [ ] `weak` 프로퍼티가 모두 Optional인가?
- [ ] 클로저 안에서 self 강한 캡처 의심 코드는 없는가?
- [ ] delegate 프로퍼티가 weak인가?
