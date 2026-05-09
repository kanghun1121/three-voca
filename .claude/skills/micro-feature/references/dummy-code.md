# Dummy Code Templates

새 Feature 모듈 생성 직후 빌드 통과를 위한 최소 코드 템플릿.
스킬의 단계 7에서 사용한다.

플레이스홀더:
- `<MODULE>`: 모듈 이름 (PascalCase, 예: `Settings`)

## 파일별 템플릿

### Interface/<MODULE>Interface.swift

```swift
import Foundation

public protocol <MODULE>Interface {
    // TODO: define public API
}
```

### Sources/<MODULE>.swift

```swift
import Foundation
import Feature<MODULE>Interface

public final class <MODULE>: <MODULE>Interface {
    public init() {}
}
```

### Testing/<MODULE>Mock.swift

Testing 타겟이 있을 때만.

```swift
import Foundation
import Feature<MODULE>Interface

public final class <MODULE>Mock: <MODULE>Interface {
    public init() {}
    
    // TODO: add mock properties to control test behavior
}
```

### Tests/<MODULE>Tests.swift

Tests 타겟이 있을 때만.

```swift
import XCTest
@testable import Feature<MODULE>

final class <MODULE>Tests: XCTestCase {
    func test_initialize_doesNotCrash() {
        _ = <MODULE>()
    }
}
```

### Example/<MODULE>ExampleApp.swift

Example 타겟이 있을 때만. SwiftUI 기반.

```swift
import SwiftUI
import Feature<MODULE>

@main
struct <MODULE>ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            <MODULE>ExampleView()
        }
    }
}

struct <MODULE>ExampleView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("<MODULE>")
                .font(.largeTitle)
                .bold()
            Text("Example App")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
```

### Example/Resources/LaunchScreen.storyboard

Example 앱 빌드에 필요. 빈 storyboard로 충분.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
          version="3.0" toolsVersion="22504" targetRuntime="iOS.CocoaTouch"
          propertyAccessControl="none" useAutolayout="YES" launchScreen="YES"
          useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES"
          initialViewController="01J-lp-oVM">
    <device id="retina6_12" orientation="portrait" appearance="light"/>
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="22500"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
    </dependencies>
    <scenes>
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <rect key="frame" x="0.0" y="0.0" width="393" height="852"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <viewLayoutGuide key="safeArea" id="6Tk-OE-BBY"/>
                        <color key="backgroundColor" systemColor="systemBackgroundColor"/>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
    <resources>
        <systemColor name="systemBackgroundColor">
            <color white="1" alpha="1" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
        </systemColor>
    </resources>
</document>
```

## 사용 절차 (단계 7)

1. 위 템플릿들을 모듈 디렉토리의 적절한 위치에 생성
2. 플레이스홀더 `<MODULE>`을 실제 모듈 이름으로 치환
3. 단계 1에서 만들지 않기로 한 타겟의 파일은 생성하지 않음
4. `tuist generate` 실행
5. 모든 Scheme 빌드 통과 확인
6. Example 앱이 있으면 시뮬레이터 실행 → "<MODULE> Example" 화면 표시 확인

여기까지 통과하면 사용자에게 보고:
> "이제 `Interface/<MODULE>Interface.swift`에 public API를 정의하고,
> `Sources/<MODULE>.swift`에 구현을 채워주세요."

## 의존하는 다른 Feature가 있을 때

Implements가 다른 Feature의 Interface를 사용하는 경우, Sources 파일에 import 추가:

```swift
// Sources/Profile.swift
import Foundation
import FeatureProfileInterface
import FeatureAuthInterface     // ← 다른 Feature는 Interface만!

public final class Profile: ProfileInterface {
    private let auth: AuthInterface
    
    public init(auth: AuthInterface) {
        self.auth = auth
    }
}
```

⚠️ `import FeatureAuth` (Implements) ❌ 절대 금지

## 자주 빠지는 실수

| 실수 | 결과 |
|------|------|
| `import Feature<MODULE>Interface`인데 모듈명 오타 | 빌드 실패 |
| `@main` 두 개 (Example 둘 이상의 App 구조체) | 빌드 실패 |
| `LaunchScreen.storyboard` 누락 | Example 앱 런치 실패 |
| Tests에서 `@testable import Feature<MODULE>Interface` (Interface는 `@testable` 필요 없음) | 비효율 |
| Testing 파일에 `import XCTest` | Testing 타겟은 framework, XCTest 의존 안 함 |
