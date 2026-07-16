# DESIGN.md

디자인 시스템은 아직 정의 중이다. 토큰을 쓸 때는 반드시 아래 기준을 따른다.

---

## 컬러

하드코딩된 색상값(`.gray`, `Color(hex:)` 등) 사용 금지.  
반드시 `DesignSystem` 모듈의 시맨틱 토큰을 사용한다.

현재 정의된 토큰:

```swift
// Backgrounds
DesignSystemAsset.Color.background.swiftUIColor
DesignSystemAsset.Color.bg.swiftUIColor
DesignSystemAsset.Color.bgMuted.swiftUIColor
DesignSystemAsset.Color.bgSubtle.swiftUIColor

// Foregrounds
DesignSystemAsset.Color.fgStrong.swiftUIColor
DesignSystemAsset.Color.fgMuted.swiftUIColor

// Borders
DesignSystemAsset.Color.border.swiftUIColor
DesignSystemAsset.Color.borderSubtle.swiftUIColor

// Semantic
DesignSystemAsset.Color.primary.swiftUIColor
DesignSystemAsset.Color.positive.swiftUIColor
DesignSystemAsset.Color.negative.swiftUIColor
DesignSystemAsset.Color.cautionary.swiftUIColor
DesignSystemAsset.Color.white.swiftUIColor

// Game / Study
DesignSystemAsset.Color.game.swiftUIColor
DesignSystemAsset.Color.game100.swiftUIColor  // ~ game400
DesignSystemAsset.Color.study100.swiftUIColor // ~ study300

// Splash
DesignSystemAsset.Color.splashBackground.swiftUIColor // #E7F3EA
```

필요한 토큰이 없으면 임의로 색상을 추가하지 말고 먼저 물어본다.

---

## 폰트

시스템 폰트(`.font(.body)` 등) 사용 금지.  
반드시 Pretendard를 사용한다.

```swift
DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 16)
DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14)
DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 18)
DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 20)
```

사용 가능한 weight: `thin`, `extraLight`, `light`, `regular`, `medium`, `semiBold`, `bold`, `extraBold`, `black`

어떤 weight를 어떤 용도에 쓸지 아직 정해지지 않았다. 새 규칙이 생기면 이 파일에 추가한다.
