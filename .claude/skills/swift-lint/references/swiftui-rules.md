# SwiftUI Rules

SwiftUI 코드에만 적용되는 룰. SwiftUI 파일이 아니면 본 파일은 로드하지 않는다.

## 1. View는 Struct로 정의

### 룰
- **모든 뷰는 `struct`로 정의**
- `@ViewBuilder` function이나 computed property로 정의하는 것은 **지양**

### 이유
1. State와 Binding 등의 관계가 명확히 정의됨. 구현부를 보지 않고도 역할을 짐작 가능.
2. 재사용으로 바꾸려면 추가 작업이 필요. 미리 struct로 정의하면 방지 가능.

### 예시

**Good ✅**
```swift
struct Item: View {
    @State private var isFavorite: Bool = false

    var body: some View {
        FavoriteButton(isFavorite: $isFavorite)
    }

    // 내부 struct로 분리 (또는 extension으로 정의해도 무방)
    struct FavoriteButton: View {
        @Binding var isFavorite: Bool

        var body: some View {
            Button {
                isFavorite.toggle()
            } label: {
                // ...
            }
        }
    }
}
```

**Bad ❌** — `@ViewBuilder` function
```swift
struct Item: View {
    @State private var isFavorite: Bool = false

    var body: some View {
        FavoriteButton()
    }

    @ViewBuilder
    private func FavoriteButton() -> some View {     // ❌
        Button {
            isFavorite.toggle()
        } label: {
            // ...
        }
    }
}
```

**Bad ❌** — computed property
```swift
struct Item: View {
    @State private var isFavorite: Bool = false

    var body: some View {
        FavoriteButton
    }

    @ViewBuilder
    var FavoriteButton: some View {                  // ❌
        Button {
            isFavorite.toggle()
        } label: {
            // ...
        }
    }
}
```

### 검토 포인트
- `@ViewBuilder` 함수 발견 → struct로 분리 제안 (P1)
- View의 computed property가 `@ViewBuilder`로 표시됨 → struct로 분리 제안 (P1)
- 함수명이 PascalCase로 View 반환 → struct여야 함을 표시 (View 함수처럼 사용)

---

## 2. 레이아웃 컨테이너는 한 View Struct에 1개

### 룰
- 한 뷰 struct에서 **레이아웃 컨테이너는 최대 1개**까지만 사용
- 2개 이상 필요하면 **하위 View struct로 분리**

### 레이아웃 컨테이너란
- `VStack`, `HStack`, `ZStack`
- `Grid`, `LazyVStack`, `LazyHStack`
- `Form`, `List` (위 컨테이너 안에 들어가는 경우 검토)

### 이유
1. 2개 이상 겹치면 배치 방향성이 일관되지 않아 가독성 ↓
2. 각 배치 방향이 무엇을 의미하는지 이름을 결정하면 가독성 ↑
3. 분리 과정에서 불필요한 컨테이너를 발견할 확률 ↑

### 예시

**Good ✅**
```swift
struct Articles: View {
    var body: some View {
        VStack {                            // ✅ 외부에 1개
            Text("Featured")
            FeaturedArticles()              // ✅ 내부 컨테이너는 별도 struct로
            Divider()
            Text("All Articles")
            AllArticles()                   // ✅
        }
    }

    struct FeaturedArticles: View {
        var body: some View {
            HStack {                         // ✅ 자기 컨테이너 1개
                NavigationLink { /*...*/ } label: { /*...*/ }
                NavigationLink { /*...*/ } label: { /*...*/ }
            }
        }
    }

    struct AllArticles: View {
        var body: some View {
            HStack {                         // ✅
                NavigationLink { /*...*/ } label: { /*...*/ }
                NavigationLink { /*...*/ } label: { /*...*/ }
            }
        }
    }
}
```

**Bad ❌**
```swift
struct Articles: View {
    var body: some View {
        VStack {
            Text("Featured")
            HStack {                         // ❌ 외부 VStack과 함께 2개
                NavigationLink { /*...*/ } label: { /*...*/ }
                NavigationLink { /*...*/ } label: { /*...*/ }
            }
            Divider()
            Text("All Articles")
            HStack {                         // ❌ 또 1개
                NavigationLink { /*...*/ } label: { /*...*/ }
                NavigationLink { /*...*/ } label: { /*...*/ }
            }
        }
    }
}
```

### 검토 포인트
- 한 `body` 안에 VStack/HStack/ZStack이 2개 이상 → 하위 struct로 분리 제안 (P1)
- 컨테이너 이름이 의미를 드러내지 못함 (예: 너무 큰 VStack) → 의미 단위 분리 제안 (P2)

---

## 3. 일반적인 SwiftUI 모범 사례 (가이드 명시는 아니지만)

다음은 가이드에 명시되지는 않았으나 일반적으로 권장되며, P2(선호)로만 제안:

### 3.1 Modifier 체이닝 줄바꿈

3개 이상 modifier 체이닝 시 한 줄에 하나씩:

```swift
// Good ✅
Text("Hello")
    .font(.title)
    .foregroundStyle(.blue)
    .padding()

// Bad ❌ (3개 이상)
Text("Hello").font(.title).foregroundStyle(.blue).padding()
```

이 룰은 본 가이드의 **파라미터 3개 이상 줄바꿈**과 일관됨 (modifier도 같은 정신).

### 3.2 @State 접근 제어

`@State`는 일반적으로 `private`:

```swift
// Good ✅
@State private var isLoading = false

// Bad ❌
@State var isLoading = false
```

### 3.3 ViewModifier extension 활용

반복되는 modifier 체인은 extension으로 추출하는 것이 좋음 (P2 제안).

---

## 빠른 체크리스트 (SwiftUI 한정)

- [ ] 모든 View가 struct로 정의됐는가?
- [ ] `@ViewBuilder` function 또는 `@ViewBuilder var ...` 사용은 없는가?
- [ ] 한 body 안에 레이아웃 컨테이너(VStack/HStack/ZStack 등)가 1개인가?
- [ ] 2개 이상이면 하위 struct로 분리되어 있는가?
- [ ] 3개 이상의 modifier 체이닝이 줄바꿈됐는가? (P2)
- [ ] `@State` 변수가 private인가? (P2)
