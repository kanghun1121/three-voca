---
name: data-model-layer
description: Tuist MicroFeature 프로젝트의 Feature 레이어 코드를 작성·수정할 때 따르는 모델 3계층 분리 규칙.
이 스킬은 Feature 안의 코드 작성을 다룬다. 모듈 스캐폴딩 자체는 tuist-microfeature-module이 담당. 둘 다 필요하면 두 스킬을 같이 사용한다.
---

작업 시작 전 필독
references/layer-rules.md를 항상 먼저 읽는다. 이 파일에 3계층 각각의 상세 스펙, 절대 규칙, 네이밍 컨벤션이 있다. 코드를 한 줄도 쓰기 전에 통독.
코드 작성 단계에서는 references/code-templates.md를 참조해 템플릿을 그대로 복사하지 말고 패턴을 따른다.

언제 트리거되는가

"로그인 화면 만들어줘"
"Settings 안에 프로필 카드 화면 추가"
"이 ViewModel에 로그인 API 붙여줘"
"홈 화면 데이터 연결해줘"
"이 Feature에 결제 결과 화면 하나 추가"
"이 화면에서 보여줄 데이터 구조 짜줘"
"create a login screen", "wire up the API in HomeFeature"

요청이 Projects/Feature/ 아래의 코드를 만들거나 고치면 사용한다.
언제 트리거하지 않는가

Domain 모듈 단독 작업 (UseCase 정의, Domain Model만 추가)
Core 모듈 작업 (네트워크·DB·로깅 인프라)
Shared 모듈 작업 (DesignSystem 컴포넌트, Util)
iOS와 무관한 Swift 작업
새 모듈을 통째로 스캐폴딩 — tuist-microfeature-module이 담당


3계층 한눈에
계층무엇을 담는가누가 소유하나Feature 안에서 보이는가DTO서버 응답 그대로 (Codable, 문자열 시간 그대로)Repository 구현부❌ 절대 불가Domain Model비즈니스 표현 (Date, enum로 정제)Domain 모듈✅ Service 호출 결과로 받음Display Model화면 표시용 (포매팅 끝난 String)Feature 모듈✅ View가 직접 사용
각 계층의 상세 스펙·절대 규칙·네이밍은 references/layer-rules.md 참조.

데이터 흐름 (단방향)
[Server JSON]
   │ JSONDecoder
   ▼
[DTO] ── Repository 구현부 내부에서만 존재
   │ DTO.toDomain()
   ▼
[Domain Model] ── Repository protocol 반환 타입, Service / UseCase가 다룸
   │ ViewModel 클래스 안에서 매핑
   ▼
[Display Model] ── View가 그대로 사용
변환은 각 경계에서 한 번씩만 일어난다.

작업 단계
Feature 안에서 새 화면·기능을 만들 때 다음 순서로 진행:
1. references/layer-rules.md 읽기
절대 규칙과 네이밍 컨벤션을 먼저 확인.
2. Display Model 먼저 정의
"이 화면이 그리려면 무엇을 알아야 하는가?"를 결정. 모든 필드는 화면이 그대로 그릴 수 있는 형태(String, 색상 토큰 등).
3. Domain Model 존재 여부 확인

이미 Domain 모듈에 있으면 그대로 사용
없으면 Domain 모듈에 추가가 필요한지 사용자에게 확인 (이건 Feature 단독 작업 범위를 벗어남)

4. DTO 위치 확인

DTO·매퍼는 Repository 쪽에 위치하도록 함
Feature 안에서 DTO를 정의하지 않는다. 이미 Feature에 DTO가 보이면 위반 → §위반 발견 시 행동

5. ViewModel 클래스 작성
Service / UseCase 호출 → Domain Model 받음 → toXxxViewState() 호출 → @Published Display Model 갱신.
구체 코드는 references/code-templates.md §F 참조.
6. View 작성
Display Model만 받아 그대로 그린다. View 안에서 추가 분기·포매팅 금지.
references/code-templates.md §G 참조.

자주 빠지는 함정
함정방지법View에서 User.createdAt을 바로 DateFormatter로 포매팅Display Model의 joinedDateText: String을 만들어 거기에 포함Domain Model에 formattedPrice 같은 화면용 프로퍼티 추가Display Model로 옮긴다Repository가 UserDTO를 그대로 반환Repository는 Domain Model을 반환. DTO는 구현부 내부에 가둔다Display Model에 Date 그대로 보유화면 표시 문자열로 변환해 String으로 보유Display Model이 Domain Model을 프로퍼티로 그대로 들고 있음필요한 필드만 평탄화해서 풀어둔다한 모델이 모든 화면을 담당 (UserDisplayModel 하나로 프로필·목록·검색결과 모두)화면 단위로 Display Model 별도 정의MVVM 클래스와 데이터 모델 둘 다 ~ViewModel 접미사데이터 모델은 ~ViewState / ~DisplayModel / ~Item으로 구분

위반 발견 시 행동
기존 코드 수정 중 다음 중 하나가 발견되면 고치는 코드를 쓰기 전에 사용자에게 알리고 진행 방향을 확인한다:

View가 Domain Model을 직접 사용 중
Domain Model에 화면용 프로퍼티가 섞여 있음
Repository protocol이 DTO를 반환 중
Display Model이 없이 ViewModel 클래스가 @Published 프로퍼티를 산발적으로 들고 있음

진행 전 사용자에게 옵션을 제시한다. 예:

현재 ProfileView가 User(Domain Model)를 직접 사용 중입니다.
A) 이번 변경에서 ProfileViewState를 도입해 정리하고 진행
B) 일관성 깨지지만 기존 패턴을 따라 Domain Model 직접 사용
어느 쪽으로 갈까요?

기본 권장은 A. 변경 범위가 너무 커지는 경우엔 B를 받아들이고 별도 리팩터 작업을 제안한다.

참조 파일
파일용도언제 읽나references/layer-rules.md3계층 상세 스펙, 절대 규칙, 네이밍 컨벤션작업 시작 전 항상references/code-templates.mdDTO/Domain/Display/매퍼/ViewModel/View 코드 템플릿실제 코드 작성 단계
의문이 들면
references/layer-rules.md §절대 규칙을 다시 읽는다. 그래도 모호하면 사용자에게 묻는다 — 잘못된 모델 분리는 한 번 자리 잡으면 되돌리기 매우 어렵다.