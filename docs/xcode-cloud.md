# Dev TestFlight 배포 (Xcode Cloud)

Xcode Cloud는 `threevoca-dev` 스킴의 `Dev` configuration을 아카이브해 Dev 전용 TestFlight 앱으로 배포한다.

## App Store Connect 사전 설정

1. Apple Developer에서 App ID `com.kangdev.threevoca.dev`를 등록한다.
2. App Store Connect에 Bundle ID `com.kangdev.threevoca.dev`를 사용하는 별도 앱 레코드를 만든다.
3. Dev 앱의 내부 테스터 그룹을 만들거나 기존 내부 테스터를 연결한다.

Prod 앱은 Bundle ID `com.kangdev.threevoca`를 사용하는 별도 앱 레코드로 운영한다. 기존 `com.kangdev.FiveVoca` 앱 레코드의 Bundle ID는 변경할 수 없다.

## Xcode Cloud 워크플로

- Scheme: `threevoca-dev`
- Archive configuration: `Dev`
- Deployment Preparation: **TestFlight (Internal Testing Only)**
- Post-action: Dev 앱에 연결된 **TestFlight Internal Testing** 그룹
- Signing: Xcode Cloud managed automatic signing
- Development Team: `W35T2QAC67`

워크플로의 Environment에는 다음 값을 Secret으로 등록한다.

| 변수 | 용도 |
|---|---|
| `SUPABASE_DEV_URL` | Dev 환경 HTTPS URL |
| `SUPABASE_DEV_ANON_KEY` | Dev 환경 공개 클라이언트 키 |
| `MW_DICTIONARY_API_KEY` | 사전 API 키 |
| `DEV_ACCOUNT_EMAIL` | 선택: 내부 테스트 계정 |
| `DEV_ACCOUNT_PASSWORD` | 선택: 내부 테스트 계정 암호 |

`ci_scripts/ci_post_clone.sh`는 Tuist 프로젝트를 생성한 뒤 `threevoca-dev`의 최종 번들 ID가 `com.kangdev.threevoca.dev`인지 검증한다. 다른 번들 ID로 해석되면 Archive 전에 빌드를 실패시킨다.

Xcode Cloud에서 기존 Prod 앱에 연결된 워크플로는 Bundle ID 변경만으로 Dev 앱 레코드에 자동 이전되지 않을 수 있다. 위 Dev 앱 레코드를 만든 후 Xcode에서 `threevoca-dev` 스킴을 기준으로 새 워크플로를 연결하거나, 기존 워크플로의 Product와 TestFlight post-action을 Dev 앱으로 다시 지정해야 한다.
