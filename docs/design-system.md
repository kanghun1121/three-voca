# Design System

컬러는 `DesignSystemColor`, 폰트는 `DesignSystemTypography`를 사용한다.

```swift
Text("단어")
    .typography(DesignSystemTypography.Pretendard.bold16)
    .foregroundStyle(DesignSystemColor.Foreground.strong)
```

Typography는 글꼴·크기·굵기를 정의한다. 자간과 행간은 별도로 지정하지 않고 폰트의 기본값을 사용한다. 화면에서 추가로 쓰는 스타일도 DS에 정의한다. Home·Stage의 공통 스타일은 각각 `DesignSystemTypography.Home`·`Stage`에 있다.

`@ScaledMetric`으로 크기를 조절하는 화면은 토큰의 `size`로 초기화하고 `scaled(to:)`로 폰트 크기를 조절한다. AttributedString을 구성할 때는 토큰의 `font`·`italicFont`를 사용한다.

Pretendard와 Roboto Mono 리소스는 DS가 보유하고 등록한다. 기존 시스템 폰트와 SF Symbols의 크기·굵기는 DS의 Pretendard 스타일로 지정한다.

Apple 로그인 버튼의 기본 제공 스타일은 로그인 화면에서 지정한다. DS는 AuthenticationServices를 참조하지 않는다. Domain·DomainInterface 제품 타겟에는 DS 의존성을 추가하지 않는다. 화면을 가진 독립 실행 타겟 DomainExample만 DS를 참조한다.

## 다크 모드

컬러는 Asset Catalog의 Any/Dark 값으로 정의하며 시스템 설정을 따른다. 앱 안에서 모드를 고정하거나 토글하지 않는다.

- 화면·카드의 기본 면은 `Background.base`, 배경 위에 떠 있는 버튼(뒤로가기, 스크롤 버튼, 오디오 버튼)은 `Background.elevated`를 쓴다. `Base.white`는 모드와 상관없이 항상 흰색이므로 게임 화면·컬러 버튼 위 글자·흰 원처럼 "흰색 자체"가 필요한 곳에만 쓴다.
- 같은 색을 채움(흰 글자를 얹는 면)과 텍스트·아이콘에 모두 쓰면 다크에서 두 대비를 한 값으로 맞출 수 없다. 채움은 `Accent.selectedBlue`·`Status.negative`, 어두운 배경 위 텍스트·아이콘은 `Accent.selectedBlueText`·`Status.negativeText`를 쓴다.
- 채움 + 흰 글자 용도로만 쓰는 토큰(`Stage.basicDark`, `Game.*`, `Gradient.*`)은 라이트·다크 값을 같게 둔다.
- Figma의 Color 컬렉션은 Light/Dark 두 모드를 가지며 값은 Asset Catalog와 같다.
