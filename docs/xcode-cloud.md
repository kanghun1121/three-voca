# develop 병합 → TestFlight (Xcode Cloud)

이 저장소의 Xcode 프로젝트와 Shared Scheme은 Tuist의 `Project.swift`에서 생성한다. `.xcodeproj`, `.xcworkspace`, `.xcscheme`은 커밋하지 않는다. Xcode Cloud는 `ci_scripts/ci_post_clone.sh`에서 Tuist 4.107.2를 설치하고 `tuist install`, `tuist generate --no-open`을 실행한다. 최초 워크플로 연결 시에는 로컬에서 `tuist install && tuist generate --no-open`으로 생성한 `FiveVoca.xcworkspace`를 Xcode로 열어야 한다. [Tuist의 Xcode Cloud 안내](https://docs.tuist.dev/en/guides/integrations/continuous-integration#xcode-cloud)

## 현재 상태 (2026-10-15)

- `PR-TestFlight-Deploy` 워크플로는 Xcode 26.3 / macOS Tahoe 26.3, iOS Archive `threevoca-dev`, `TestFlight (Internal Testing Only)`, 내부 그룹 `Test`로 구성되어 있다.
- `SUPABASE_DEV_URL`, `SUPABASE_DEV_ANON_KEY`, `MW_DICTIONARY_API_KEY`는 Xcode Cloud의 **Shared Environment Variables**에 Secret으로 저장하고 이 워크플로에만 적용했다. 값은 저장소에 없다.
- 수동 실행한 [Build 3](https://appstoreconnect.apple.com/teams/e0065728-0630-4b06-9561-31c2f1d10e95/xcode-cloud/products/AA7C839C-923B-4056-835A-74BC6A5DD17A/builds/762c0e4d-144a-4477-abe1-9680febd11d4)는 Archive와 내부 TestFlight Post-action이 성공했다. App Store Connect의 [TestFlight `1.0.0 (3)`](https://appstoreconnect.apple.com/teams/e0065728-0630-4b06-9561-31c2f1d10e95/apps/6783802903/testflight/ios/e114beb6-cb88-4396-a026-e9f20a30941e)는 `테스트 중`이며 `Test` 그룹에 배정되어 있다. 실제 iPhone 설치는 아직 확인하지 않았다.
- 첫 수동 빌드는 필수 환경 변수가 없어 Post-clone에서 실패했다. Secret을 등록한 뒤 두 번째 빌드에서 Archive가 성공했고, 내부 배포 설정을 추가한 세 번째 빌드에서 TestFlight 제공까지 확인했다. 빌드 로그와 오류를 기준으로 수정했다.
- 이 GitHub 저장소는 **공개**되어 있다. 외부 PR의 코드를 Secret이 있는 빌드 환경에서 자동 실행하지 않도록, Xcode Cloud Start Condition을 **Branch Changes → develop**으로 설정했다. PR 생성·업데이트 자체는 배포를 시작하지 않는다.
- `develop`은 기존 `dev`의 커밋에서 생성했다. GitHub의 `develop requires pull request` 규칙은 직접 Push와 강제 Push를 막고 PR 병합을 요구한다. 따라서 정상적인 `develop` 변경은 PR 병합을 통해 발생한다. 현재 기본 브랜치와 기존 팀 PR 대상은 여전히 `dev`다.
- 이 브랜치의 Tuist/Post-clone 변경은 아직 `develop`에 병합되지 않았다. 병합 이후 처음 실행되는 자동 빌드의 결과를 별도로 확인해야 한다. 수동 빌드 3의 성공은 Archive·TestFlight 경로를 검증한 결과다.

## 최초 설정 및 유지보수

1. App Store Connect에 Bundle ID `com.kangdev.FiveVoca`의 앱 레코드와 내부 테스터 그룹을 준비한다. Xcode Cloud에 GitHub 저장소 `kanghun1121/three-voca` 접근 권한을 부여한다.
2. Xcode에서 생성된 `FiveVoca.xcworkspace`를 열어 해당 앱의 Xcode Cloud 첫 워크플로를 연결한다. Apple은 첫 연결에 Xcode 사용을 요구한다. 워크플로 이름은 `PR-TestFlight-Deploy`로 한다. [Apple 최초 설정 안내](https://developer.apple.com/documentation/xcode/configuring-your-first-xcode-cloud-workflow)
3. Start Condition은 **Branch Changes**, Source Branch는 `develop`, Auto-cancel Builds는 **Enabled**로 설정한다. `develop` 브랜치에는 GitHub 규칙 `develop requires pull request`를 적용해 직접 Push와 강제 Push를 막는다. 규칙에 우회 사용자를 추가하면 병합 없이도 자동 배포가 시작될 수 있다.
4. Platform은 **iOS**, 모든 Action의 Scheme은 **threevoca-dev**로 지정한다. Archive Action은 필수이고 Deployment Preparation은 **TestFlight (Internal Testing Only)**로 한다. Build/Test Action은 필요할 때 같은 Scheme으로 추가한다. 다른 Scheme을 선택하지 않는다.
5. Post-action에 **TestFlight Internal Testing**을 추가하고 1번의 내부 테스터 그룹을 선택한다. 정식 App Store 배포용 Post-action은 추가하지 않는다. [Apple 배포 워크플로 안내](https://developer.apple.com/documentation/xcode/creating-a-workflow-that-builds-your-app-for-distribution)
6. Shared Environment Variables에서 아래 값을 **Secret**으로 등록하고 해당 워크플로에만 적용한다. 인증서와 프로비저닝 프로파일은 저장소에 넣지 않고 Xcode Cloud의 자동 서명을 사용한다.

| 변수 | 용도 |
|---|---|
| `SUPABASE_DEV_URL` | Dev 환경 HTTPS URL |
| `SUPABASE_DEV_ANON_KEY` | Dev 환경 공개 클라이언트 키 |
| `MW_DICTIONARY_API_KEY` | 사전 API 키 |
| `DEV_ACCOUNT_EMAIL` | 선택: 내부 테스트 계정 |
| `DEV_ACCOUNT_PASSWORD` | 선택: 내부 테스트 계정 암호 |

서명용 Apple Developer Team ID는 Dev 구성의 `DEVELOPMENT_TEAM`에 지정한다. Xcode Cloud의 `CI_TEAM_ID`는 UUID이므로 서명 설정에 사용하지 않는다. 필수 변수가 빠지면 Archive 전에 빌드가 실패한다. 앱 버전은 Tuist에서 `1.0.0`으로 지정하며 빌드 번호는 Xcode Cloud가 자동으로 증가시킨다. 기존 TestFlight 빌드와 번호가 충돌하면 App Store Connect → Xcode Cloud → Settings → Build Number에서 다음 번호를 조정한다. [Apple 빌드 번호 안내](https://developer.apple.com/documentation/xcode/setting-the-next-build-number-for-xcode-cloud-builds)

## 검증

1. `develop` 대상 PR을 열고, 생성·업데이트만으로 Xcode Cloud 빌드가 시작되지 않는지 확인한다. PR을 병합한 뒤 `develop`의 새 커밋으로 빌드가 시작되는지 확인한다. Branch Changes 조건은 PR 상태가 아닌 브랜치 변경을 감지하므로 `develop`의 직접 Push를 막는 GitHub 규칙이 필요하다.
2. Archive가 `threevoca-dev` 및 `Dev` 구성으로 수행됐는지 확인한다. 실패 시 App Store Connect → 앱 → Xcode Cloud → Builds에서 해당 Action의 Logs를 확인한다.
3. TestFlight 내부 그룹에 새 빌드가 표시되고 iPhone에서 설치되는지 확인한다.
4. 다른 대상 브랜치 PR의 병합은 이 워크플로를 시작하지 않아야 한다. `develop`에 새 병합이 빠르게 연속되면 이전 진행 중 빌드가 자동 취소되는지 확인한다.

이 구성에서는 병합 전 PR에 Xcode Cloud 상태가 표시되지 않는다. 병합 전 검사까지 필요하면 Secret을 공유하지 않는 별도 검증 흐름을 설계해야 한다.

Xcode Cloud 첫 연결 또는 첫 빌드에서 생성 프로젝트를 찾지 못한다면 Cloud의 Post-clone 스크립트 실행 여부를 확인한다. 이 Tuist 구성은 수동 Xcode Cloud Archive로 검증했다. [Apple 프로젝트 요구사항](https://developer.apple.com/documentation/xcode/setting-up-your-project-to-use-xcode-cloud)
