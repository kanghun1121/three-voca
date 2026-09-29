---
paths:
  - "Projects/Feature/**/*.swift"
  - "Projects/App/**/*.swift"
---

# 컬러는 DesignSystemAsset만 사용

- `Color(red:...)`, `Color(hue:...)`, `UIColor(red:...)` 등 인라인 Color 생성 금지.
- 반드시 `DesignSystemAsset.xxx.swiftUIColor`를 사용한다.
- 필요한 색이 DesignSystemAsset에 없으면 직접 만들지 말고 추가를 제안한다.
- `Color.white`/`Color.black` 등 시스템 표준 색상은 예외 여부를 사용자에게 확인한다.
