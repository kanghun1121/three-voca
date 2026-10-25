# voca-bot: PR 리뷰 첫 단계

`voca-bot`은 새 PR이 열리면 GitHub Actions의 호스팅 실행 환경에서 변경 내용을 읽고, `agent-vovo` GitHub App 계정으로 요약 리뷰와 필요한 라인 코멘트를 게시합니다. 개인 컴퓨터가 켜져 있을 필요가 없습니다.

## 처음 한 번 연결하기

1. [GitHub App 설정](https://github.com/settings/apps/new)에서 표시 이름 `agent-vovo`로 등록합니다. Homepage URL에는 이 저장소 주소를 넣고, Webhook은 비활성화합니다. Repository permission **Pull requests: Read & write**만 설정합니다.
2. App을 이 저장소에만 설치하고 App 설정에서 private key를 생성합니다.
3. 저장소의 **Settings → Secrets and variables → Actions**에 다음을 설정합니다.

   | 종류 | 이름 | 값 |
   | --- | --- | --- |
   | Variable | `VOCA_BOT_CLIENT_ID` | GitHub App의 Client ID |
   | Secret | `VOCA_BOT_PRIVATE_KEY` | 다운로드한 `.pem` 파일의 전체 내용 |
   | Secret | `VOCA_BOT_OPENAI_API_KEY` | OpenAI API 키 |
   | Variable (선택) | `VOCA_BOT_MODEL` | 사용할 모델. 기본값 `gpt-6.1-sol` |

4. 이 워크플로 파일을 기본 브랜치 `dev`에 반영하면 이후 **새로 열리는 일반 PR**과 **초안에서 리뷰 준비 상태로 바뀐 PR**에서 자동으로 실행됩니다. 이미 열린 일반 PR은 이 첫 단계의 대상이 아닙니다.

GitHub Actions의 `agent-vovo PR review` 실행 기록에서 실패 원인을 확인할 수 있습니다. API 사용량은 연결한 OpenAI 계정에 청구됩니다.

이 저장소는 공개 저장소입니다. GitHub는 `pull_request_target` 이벤트에 대한 기본 정책을 강화하고 있으므로, 워크플로가 정책으로 차단되면 저장소의 Actions 정책에서 이 이벤트를 명시적으로 허용해야 합니다. 이 워크플로는 신뢰된 기본 브랜치만 체크아웃하며 PR 코드는 실행하지 않습니다. [GitHub 보안 안내](https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target)

## 작동 범위

- PR의 변경 파일과 diff를 읽습니다. PR 코드를 체크아웃하거나 실행하지 않습니다.
- 변경 내용에 맞는 프로젝트 문서와 리뷰 스킬을 선택해 읽습니다. [리뷰 우선순위](review-policy.md)에 따라 발견 사항을 P1·P2·P3으로 표시합니다. 디자인 에셋만 바뀐 PR은 AI 리뷰를 건너뜁니다.
- 변경된 줄의 좌표를 검증한 뒤 최대 20개의 라인 코멘트와 한 개의 요약 리뷰를 함께 게시합니다. 확실한 문제가 없으면 라인 코멘트는 없을 수 있습니다.
- 같은 커밋에 대한 `voca-bot` 리뷰가 있으면 중복 게시를 건너뜁니다.
- 한 번에 최대 100개 파일과 90,000자의 diff를 읽습니다. 더 큰 PR은 리뷰에 범위 제한을 표시합니다.
- 리뷰는 참고 의견으로 게시되며 승인이나 변경 요청 상태를 자동으로 선택하지 않습니다.

GitHub의 [GitHub App 등록 안내](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app), [Actions에서 App 인증](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/making-authenticated-api-requests-with-a-github-app-in-a-github-actions-workflow), [PR 리뷰 API](https://docs.github.com/en/rest/pulls/reviews)를 따릅니다.
