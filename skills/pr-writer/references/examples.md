# PR 구조 예시

변경 규모가 비슷한 예시에서 그룹 사용 여부, 압축 수준, 검증 위치와 변경 목적을 전하는 방식을 참고한다.
문장을 복사하지 않고 실제 diff와 실행 기록으로 내용을 확인한다. Good 예시는 저장소의 고정 템플릿 섹션을 쓴다.

## 단순 기능 PR: 그룹 없이 작성

변경: Spelling 입력을 TextField로 변경, 제출 버튼·Return 제출, 공백 포함 정답 검사.

### Bad

```markdown
## 📝 작업 내용

**Spelling**
- TextField 추가
- 버튼 추가
- Return 이벤트 추가
- 공백 비교 로직 추가
```

### Good

```markdown
## 연관 이슈

#123

## 📝 작업 내용

- 입력 즉시 판정되던 Spelling을 TextField 입력 후 제출 방식으로 변경
- 제출 버튼과 키보드 Return으로 정답 제출 지원
- 띄어쓰기를 포함한 정답 검증 추가

## 🖼️ 스크린샷 (선택)

- iOS Simulator에서 Spelling 입력 화면 확인
```

### Why

하나의 목적에 속한 세 동작이므로 그룹 제목이 필요 없다. 첫 불릿에 기존 문제와 새 동작을 함께 담아
변경 이유를 나중에도 알 수 있게 한다. 화면 확인은 실제 수행한 경우에만 쓴다.

## 여러 화면의 기능 PR: 화면 흐름별 그룹

변경: Home의 이어하기와 Lesson의 진행 상태 표시를 같은 학습 재개 흐름에 맞게 변경.

### Bad

```markdown
## 📝 작업 내용

- HomeView 버튼 텍스트 변경
- HomeViewModel 분기 추가
- LessonView ProgressBar 수정
- LessonStore 상태 매핑 수정
```

### Good

```markdown
## 연관 이슈

#124

## 📝 작업 내용

**학습 시작**
- 진행 중인 학습이 있으면 Home에서 이어하기 동작 제공

**Lesson**
- 이어서 진입한 학습의 진행 상태를 Lesson 화면에 반영

## 🖼️ 스크린샷 (선택)

- Home 이어하기와 Lesson 진행 화면 이미지 첨부
```

### Why

같은 목표의 여러 화면 변경을 사용자 흐름으로 연결한다. 이미지 문구는 실제 첨부한 경우에만 쓴다.

## 기능과 버그 수정 PR: 중요도 순서

변경: WordGame Spelling 입력 개선, 관련 Recognition 긴 단어 줄바꿈 수정, Spelling 테스트 수정,
실제로 해당 테스트 12개 통과.

### Bad

```markdown
## 📝 작업 내용

- SpellingViewModelTests 수정 및 테스트 완료
- RecognitionView fontSize 계산 수정
- TextField, 삭제 버튼, 제출 버튼, Return 처리 추가
```

### Good

```markdown
## 연관 이슈

#125

## 📝 작업 내용

**WordGame**
- Spelling 입력을 TextField 기반으로 변경하고 제출·전체 삭제·띄어쓰기 검증 지원
- 긴 Recognition 단어가 줄바꿈되지 않도록 화면 너비에 맞춰 표시
- 새 Spelling 입력 동작에 맞게 관련 테스트 수정

**검증**
- `SpellingViewModelTests` 12개 통과

## 🖼️ 스크린샷 (선택)

- iOS Simulator에서 Spelling과 Recognition 화면 확인
```

### Why

핵심 기능과 사용자에게 보이는 버그를 먼저 둔다. 테스트 코드 수정과 실제 테스트 성공을 분리한다.
테스트 수와 화면 확인은 실행 기록이 있을 때만 쓴다.

## Example / Mock이 많은 PR: 시나리오로 압축

변경: Home·ChatBot·Lesson·WordGame의 상태별 Mock 추가, Login Example 제거. Example 구성이
Primary Change이고 별도의 앱 동작 변경은 없음.

### Bad

```markdown
## 📝 작업 내용

- Lesson Example 0/42 추가
- Lesson Example 15/39 추가
- Lesson Example 99/99 추가
- Home happyPath 추가
- Home emptyPath 추가
- ChatBot 로그인 Mock 추가
- WordGame Mock 추가
- Login Example 삭제
```

### Good

```markdown
## 연관 이슈

#126

## 📝 작업 내용

**학습 Example**
- 진행 상태별 화면을 따로 확인할 수 있도록 Home·Lesson에 미진행·진행 중·완료 시나리오 추가
- WordGame에 주요 입력 상태별 Mock 추가

**대화 Example**
- ChatBot의 로그인 상태별 응답 Mock 추가
- 사용하지 않는 Login Example 제거

## 🖼️ 스크린샷 (선택)

- 없음
```

### Why

개별 데이터 값 대신 시나리오 차이를 보여준다. 정확한 값이 경계 조건의 핵심일 때만 짧게 남긴다.
시각적 변경이 없으면 스크린샷 섹션에 테스트 결과를 대신 넣지 않는다.

## 독립 변경이 섞인 PR: 분리 후보 알림

변경: WordGame 입력 UI 변경과 관련 테스트 수정, app-to-figma 자동화 Skill 추가.

### Bad

```markdown
## 📝 작업 내용

- WordGame과 개발 환경 개선
```

### Good

PR 본문 밖에서 먼저 알림:

> WordGame 입력 UI와 app-to-figma 자동화는 함께 revert하거나 같은 리뷰어가 검토할 필요가
> 적어 별도 PR 후보입니다. 현재 브랜치나 커밋은 자동으로 분리하지 않았습니다.

본문만 작성한다면 각 목적을 숨기지 않고 분리해 기술:

```markdown
## 연관 이슈

#127

## 📝 작업 내용

**WordGame**
- Spelling 입력을 TextField 기반으로 변경하고 관련 테스트 수정

**개발 도구**
- app-to-figma 자동화 Skill 추가

## 🖼️ 스크린샷 (선택)

- 없음
```

### Why

하나의 구체적인 제목으로 전체를 설명하기 어렵고 독립적으로 revert할 수 있다. 생성 요청이라면
원격 PR 생성 전에 분리 후보를 짧게 알린다. 자동으로 브랜치·커밋을 나누지 않는다.
