---
name: app-to-figma
description: 구현된 iOS 앱을 실제로 실행·조작해 화면을 캡처하고, Figma에 정확히 재구성한 뒤 사용된 Token과 Component를 Design System으로 정리한다.
argument-hint: '[대상 화면 또는 사용자 시나리오]'
---

# App to Figma

현재 구현된 iOS 앱을 Source of Truth로 사용해 실제 화면을 Figma로 재구성하고 Design System을 정리한다.

새로운 UI를 창작하지 않는다.

## Tools

- `XcodeBuildMCP`: 앱 Build, Simulator 설치 및 실행
- `agent-device`: 앱 조작, 화면 이동, Screenshot 캡처
- `Figma MCP`: Reference 저장, 화면 재구성, Overlay 검증, Design System 정리

## Workflow

### 1. 작업 범위 확인

`$ARGUMENTS`에서 재구성할 화면 또는 사용자 시나리오를 확인한다.

예:

```text
Home
Calendar
Detail
로그인 후 Home
첫 번째 항목 선택 후 Detail
```

사용자가 범위를 지정하지 않았다면 앱의 주요 Navigation을 기준으로 핵심 화면만 수집한다.

모든 화면과 상태를 무제한으로 탐색하지 않는다.

### 2. 앱 실행

XcodeBuildMCP로 프로젝트와 실행 가능한 Scheme을 확인한다.

적절한 Simulator를 선택해 다음을 수행한다.

```text
Build
→ Install
→ Launch
```

단순 Build 성공이 아니라 앱이 실제로 실행된 상태까지 확인한다.

### 3. 화면 이동

agent-device로 현재 앱 상태를 확인한다.

목표 화면까지 실제 사용자 흐름을 따라 이동한다.

필요한 경우 다음 동작을 수행한다.

- tap
- swipe
- scroll
- text input
- navigation
- tab selection

좌표를 임의로 추측하기보다 확인 가능한 UI와 현재 화면을 기준으로 조작한다.

### 4. Screenshot 캡처

목표 화면에 도달하면 화면이 안정될 때까지 확인한다.

다음 상태에서는 캡처하지 않는다.

- transition 진행 중
- loading 진행 중
- 의도하지 않은 keyboard 표시
- alert 또는 popup이 화면을 가림

안정된 상태에서 Screenshot을 캡처한다.

여러 화면은 구분 가능한 이름으로 관리한다.

```text
home.png
calendar.png
detail.png
```

### 5. Figma Reference 저장

Figma MCP로 Screenshot을 Reference 영역에 배치한다.

```text
References
├── Home
├── Calendar
└── Detail
```

Reference는 최종 디자인이 아니라 비교 기준이다.

작업이 끝날 때까지 유지한다.

### 6. 동일 규격 Frame 생성

각 Screenshot과 정확히 동일한 width와 height의 Figma Frame을 만든다.

예:

```text
Screenshot 390 × 844
Frame      390 × 844
```

규격이 다르면 Overlay 검증을 진행하지 않는다.

### 7. 화면 재구성

Screenshot을 분석해 편집 가능한 Figma Layer로 화면을 재구성한다.

가능하면 다음을 사용한다.

- Frame
- Auto Layout
- Text
- Shape
- Image
- Divider
- 반복 UI 구조

Screenshot 자체를 최종 화면으로 사용하지 않는다.

Layout과 계층 구조를 먼저 맞춘 뒤 세부 스타일을 조정한다.

### 8. Overlay 검증

원본 Screenshot과 재구성된 Frame을 동일 위치에 정확히 포갠다.

```text
Screenshot
    +
Figma Frame
    ↓
Overlay
```

Opacity를 조절해 오차를 확인한다.

다음 순서로 비교한다.

1. Frame 크기
2. 전체 Layout
3. 요소 위치
4. Width / Height
5. Margin / Spacing
6. Typography
7. Radius / Border
8. Color / Effect

### 9. 오차 보정

차이가 발견되면 해당 요소를 수정한다.

한 번 비교하고 종료하지 않는다.

```text
Rebuild
   ↓
Overlay
   ↓
Difference
   ↓
Adjust
   ↓
Overlay
```

눈에 띄는 위치·크기·간격 차이가 남아 있으면 완료로 처리하지 않는다.

### 10. 전체 화면 검증

각 대상 화면이 Overlay 검증을 통과했는지 확인한다.

검증에 실패한 화면은 완료된 Screen으로 처리하지 않고 Design System 분석에서도 제외한다.

### 11. Design System 추출

검증된 모든 화면을 함께 분석한다.

실제로 반복되는 항목만 추출한다.

**Foundations**

- Color
- Typography
- Spacing
- Radius
- Border
- Effect

**Components**

- Button
- Card
- Navigation
- Tab
- List Row
- 기타 반복 UI

비슷하다는 이유만으로 무조건 통합하지 않는다.

같은 역할과 구조를 가진 요소인지 확인한다.

실제 화면에 존재하지 않는 Token이나 Variant를 미리 만들지 않는다.

### 12. Design System 적용

추출한 Token과 Component를 재구성된 Screen에 적용한다.

가능하면 다음 구조로 정리한다.

```text
Figma
├── References
├── Screens
└── Design System
    ├── Foundations
    │   ├── Colors
    │   ├── Typography
    │   ├── Spacing
    │   └── Radius
    └── Components
```

Design System을 만들고 실제 Screen이 사용하지 않는 상태로 남기지 않는다.

## Failure Handling

- 실행 가능한 프로젝트나 Scheme을 찾지 못하면 추측하지 않고 중단한다.
- 적절한 Simulator가 없으면 사용 가능한 Simulator를 확인한다.
- Build, Install, Launch 중 하나라도 실패하면 화면 캡처를 진행하지 않는다.
- 목표 화면에 도달하지 못하면 임의로 화면을 추측해 Figma로 만들지 않는다.
- Screenshot이 잘못되면 해당 화면만 다시 캡처한다.
- Figma Frame과 Screenshot 규격이 다르면 먼저 규격을 수정한다.
- Overlay 검증에 실패한 화면은 Design System 분석에서 제외한다.
- 여러 화면 중 일부만 실패하면 성공한 화면은 유지한다.
- 실패한 화면과 원인은 최종 결과에 별도로 남긴다.

## Done

다음을 모두 만족한 화면만 완료로 본다.

- 실제 앱 화면 Screenshot 수집 완료
- Screenshot과 동일 규격의 Figma Frame 생성
- 편집 가능한 Layer로 화면 재구성
- Screenshot과 Overlay 검증 완료
- 눈에 띄는 Layout 오차 보정 완료

전체 작업은 다음까지 완료되어야 한다.

- 검증된 Screen 정리
- 반복 Token 추출
- 반복 Component 추출
- Design System 적용

## Principles

**앱이 Source of Truth다**

```text
Implemented App
      ↓
Screenshot
      ↓
Verified Figma
      ↓
Design System
```

**Screenshot은 Reference다**

Screenshot 자체가 최종 결과물이 아니다.

**검증 없는 재구성은 완료가 아니다**

반드시 동일 규격으로 포개어 비교하고 보정한다.

**Design System은 마지막에 정리한다**

정확히 재구성된 여러 화면의 실제 반복 패턴에서 추출한다.

**과도하게 추상화하지 않는다**

현재 화면에서 실제로 필요한 Token과 Component만 만든다.

미래의 재사용을 예상해 불필요한 구조를 추가하지 않는다.
