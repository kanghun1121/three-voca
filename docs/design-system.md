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
