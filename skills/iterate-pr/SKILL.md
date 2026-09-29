---
name: iterate-pr
description: 현재 브랜치 PR의 CI 체크가 통과할 때까지 원인을 고치고 커밋·푸시를 반복한다. "CI 고쳐줘", "PR 체크 그린으로 만들어줘", "CI 실패 원인 찾아서 고쳐줘"처럼 자동 체크를 통과시키라는 요청일 때 트리거한다.
---

# Iterate PR (Solo)

현재 PR의 CI 체크를 끝날 때까지 몰아간다. CI 출력과 저장소 자체가 근거의 원천이다.
사람 리뷰·승인·merge는 다루지 않는다.

## 요구 사항

- 저장소 루트에서 실행한다.
- 인증된 `gh`와 push 권한이 필요하다 (PR 업데이트가 요청 범위에 포함될 때).

## 경계

- GitHub 리뷰, 리뷰 코멘트, 리뷰 스레드, 봇 피드백을 가져오지 않는다.
- Draft PR을 ready로 바꾸거나, 리뷰를 요청하거나, 승인을 기다리거나, merge·rebase하거나,
  브랜치 보호를 우회하지 않는다.
- CI를 초록으로 만들려고 체크를 약화·스킵·삭제하지 않는다.
- 사람 승인 게이트나 정보성 체크(지금 이 저장소엔 없지만 나중에 Codecov 등이 추가되면)는
  완료 여부 판단에서 제외한다.
- 변경은 실패한 체크의 근본 원인에만 한정한다.

## 이 저장소의 체크 구성

PR엔 체크가 `CI / build-and-test` 하나뿐이다 (`.github/workflows/ci.yml`,
`tuist install && tuist generate --no-open` 후 `tuist test AllTest`). 실행 여부를 여러
버킷(actionable/informational/human-gate)으로 분류할 필요가 없을 만큼 단순하다 — 별도
분류 스크립트 없이 `gh pr checks`만으로 충분하다.

## 워크플로

### 1. PR과 요청 범위 확인

```bash
gh pr view --json number,url,headRefName,baseRefName,headRefOid,isDraft,reviewDecision,mergeStateStatus
```

현재 브랜치에 PR이 없으면 멈춘다. Draft PR은 살펴보고 고칠 수 있지만, 사용자가 별도로
요청하지 않으면 ready로 바꾸지 않는다.

상태 조회나 원인 진단만 요청받았으면 읽기 전용으로 남아 원인만 보고한다. CI를 고치라거나
PR을 업데이트하라거나 그린이 될 때까지 반복하라는 요청이면 아래 수정→커밋→푸시 루프를 수행한다.

### 2. 체크 상태 확인

```bash
gh pr checks --json name,state,bucket,link
```

| 상태 | 조치 |
|---|---|
| `pending`/`in_progress` | `gh pr checks --watch`로 대기 |
| `failure` | 3단계로 원인 조사 |
| `success` | 성공 보고 후 종료 |
| 체크가 등록되지 않음 | 잠시 대기 후 재확인. 계속 없으면 보고 후 중단 |

### 3. 실패 조사

실패한 체크마다:

1. run-id는 `gh pr checks --json link`의 URL에서 얻는다. 전체 실패 로그를 받는다:
   ```bash
   gh run view <run-id> --log-failed
   ```
2. assertion·exception·빌드 에러·타입 에러를 원인 코드까지 추적한다.
3. 수정하기 전에 근본 원인을 먼저 말한다.
4. 같은 결함이 다른 곳에도 있을 수 있으면 관련 호출부도 검색한다.
5. 원인을 고친다. 고친 것을 실제로 검증하는 회귀 테스트가 필요하면 추가한다.

취소된 job, 인프라 장애, 인증·시크릿 누락, 외부 서비스 불가는 인프라 문제로 취급한다 —
이를 보정하려고 제품 코드를 바꾸지 않는다. 상태를 그대로 보고한다.

### 4. 로컬 검증

CI가 실제로 돌리는 것과 같은 명령으로 재현한다:

```bash
tuist test AllTest
```

더 좁게 재현할 수 있으면(특정 타겟/테스트만) 그것부터 돌리고, 통과하면 `AllTest` 전체로
넓힌다. 로컬 검증이 실패하는 상태로는 push하지 않는다.

### 5. 커밋 & 푸시

최종 diff를 확인하고 수정에 필요한 파일만 스테이징한다. `commit` 스킬로 하나의 원자적
커밋을 만들고 푸시한다:

```bash
git push
```

원래 요청이 원격 PR 업데이트까지 허락한 게 아니면, 로컬 검증까지만 하고 diff를 보여주는
데서 멈춘다.

### 6. 다시 모니터링

```bash
gh pr checks --watch
```

- 다시 실패하면 2단계부터 반복한다.
- 전부 통과하면 PR URL과 통과한 체크를 보고한다.
- 체크가 사라지거나 계속 등록되지 않으면 보고 후 중단한다.

체크가 도는 동안 리뷰 코멘트를 폴링하지 않는다.

## 멈추는 조건

다음이면 멈추고 사용자에게 확인한다:

- 같은 근본 원인이 두 번 고쳐도 남아있다.
- 제품 결정이나 애매한 동작 변경이 필요하다.
- 브랜치를 rebase하거나 충돌을 풀어야 한다.
- 인증·권한·시크릿·할당량·외부 인프라가 막고 있다.

성공은 "실행 가능한 자동 체크가 전부 통과"까지다. 사람 승인, draft 상태, merge 준비·완료는
이 스킬의 범위 밖이다.

## 참고

- 원본 스펙은 `uv run scripts/fetch_pr_checks.py`/`monitor_pr_checks.py`라는 전용 Python
  스크립트로 체크를 여러 버킷으로 분류했다. 이 저장소는 `uv`를 쓰지 않고 PR 체크도
  `CI / build-and-test` 하나뿐이라, 그 분류 스크립트 없이 `gh pr checks`만으로 대체했다.
  체크 종류가 늘어나 분류가 실제로 어려워지면 그때 스크립트를 추가한다.
- 제목/본문 작성은 `pr-writer`, 버그·보안 자체를 찾는 건 `find-bugs`, PR 종합 판단은
  `code-review`가 담당한다. 이 스킬은 CI가 이미 실패로 지적한 것만 고친다.
