# 린트 Example Cases

기준: [lint.md](../lint.md)

## 네이밍

Good Case — 타입과 값의 역할을 이름에 드러내고, 액션 핸들러는 대상 뒤에 동작을 붙인다.

```swift
struct AudioPlayerState {
    let isPlaying: Bool
    let words: [String]
}

func audioButtonTapped() { }
```

Bad Case — 상태나 동작이 모호하거나 액션 핸들러의 순서를 뒤집는다.

```swift
struct audioPlayerState {
    let flag: Bool
    let word: [String]
}

func tapAudioButton() { }
```

## 파라미터 줄바꿈

Good Case — 일반 인자가 두 개면 한 줄, 세 개면 각각 한 줄에 둔다. 호출에도 같은 기준을 적용한다.

```swift
func select(id: String, animated: Bool) { }

func load(
    id: String,
    page: Int,
    limit: Int
) { }

load(
    id: "word_1",
    page: 1,
    limit: 20
)
```

Bad Case — 일반 인자 세 개를 한 줄에 모은다.

```swift
func load(id: String, page: Int, limit: Int) { }
```

## Import 정렬

Good Case — 필요한 모듈만 Apple Framework, 내부 Module, Third Party 순서로 묶고 각 그룹을 정렬한다.

```swift
import Foundation
import SwiftUI

import DesignSystem
import DomainInterface

import Dependencies
```

Bad Case — 그룹 순서가 섞이고 같은 모듈을 중복으로 가져온다.

```swift
import Dependencies
import SwiftUI
import DesignSystem
import Foundation
import SwiftUI
```

## 주석

Good Case — 코드만으로 드러나지 않는 반환 조건을 설명한다.

```swift
/// 캐시에 없으면 `nil`을 반환하며 네트워크를 호출하지 않는다.
func cachedWord(id: String) -> Word? { nil }
```

Bad Case — 작업 이력이나 자명한 동작을 코드 주석에 남긴다.

```swift
// 처음엔 공유 헬퍼로 뺐다가 호출부가 적어서 인라인으로 되돌렸다.
// 단어를 반환한다.
func cachedWord(id: String) -> Word? { nil }
```

## 프로퍼티 순서

Good Case — 저장 프로퍼티를 계산 프로퍼티보다 먼저 둔다.

```swift
struct WordListState {
    var words: [Word]

    var isEmpty: Bool { words.isEmpty }
}
```

Bad Case — 계산 프로퍼티 뒤에 저장 프로퍼티를 둔다.

```swift
struct WordListState {
    var isEmpty: Bool { words.isEmpty }

    var words: [Word]
}
```

## 클로저

Good Case — 마지막 클로저에 후행 클로저를 사용하고, 문맥상 명확한 인자 타입은 생략한다.

```swift
let terms = words.map { word in word.term }
```

Bad Case — 불필요한 괄호와 타입 표기를 추가한다.

```swift
let terms = words.map({ (word: Word) -> String in word.term })
```

## Task에서 self 캡처

Good Case — 완료되는 작업은 실행 중에 필요한 객체를 캡처하고, 작업이 끝나면 캡처를 해제한다.

```swift
func saveButtonTapped() {
    Task {
        await save()
    }
}
```

Bad Case — 작업이 끝나는지 확인하지 않고 모든 `Task`에 `[weak self]`를 붙인다. 이 경우 실행 전에 `self`가 사라지면 저장 동작을 건너뛴다.

```swift
func saveButtonTapped() {
    Task { [weak self] in
        await self?.save()
    }
}
```

관찰 스트림처럼 오래 지속되는 `Task`는 소유 객체가 사라질 때 취소되는지 확인한다. `[weak self]`만으로 작업의 수명 관리가 끝나지는 않는다.
