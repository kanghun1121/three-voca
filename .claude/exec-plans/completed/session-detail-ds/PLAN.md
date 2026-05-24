# PLAN: SessionDetail 디자인시스템 적용 및 단어 미리보기 UI 개선

- 작업 ID: `session-detail-ds`
- 생성일: 2026-05-24
- 기반 브랜치: feat/harness-docs (구현 완료 후 소급 문서화)
- Worktree: `.claude/worktrees/session-detail-ds`

---

## 목표

SessionDetail 화면의 모든 UI 컴포넌트에 DesignSystem(Pretendard 폰트, 색상 토큰)을 통일 적용하고,
WordPreviewSection의 단어 미리보기를 동적 확장/축소 UI로 개선한다.

---

## 사전 검토

- [x] docs/ARCHITECTURE.md 검토 완료
- [x] 관련 docs/ 문서 검토 완료
- [x] 영향받는 모듈/파일 파악 완료

---

## 단계별 계획 (구현 완료)

| 단계 | 작업 | 파일 |
|------|------|------|
| 1 | DesignSystem 색상 에셋 8개 추가 | Colors.xcassets/BGMuted, BGSubtle, Background, Border, BorderSubtle, FGMuted, Game, White |
| 2 | SessionDetailViewState: previewItems/moreText → words | SessionDetailViewState.swift |
| 3 | Session+ViewState: 프리뷰 로직 제거, 전체 목록 전달 | Session+ViewState.swift |
| 4 | ActionButtonsSection: DesignSystem 버튼 스타일 적용 | Components/ActionButtonsSection.swift |
| 5 | RecordCard: Pretendard 폰트 + fgMuted/fgStrong 색상 | Components/RecordCard.swift |
| 6 | SessionHeaderSection: Pretendard 폰트 계층 적용 | Components/SessionHeaderSection.swift |
| 7 | WordPreviewSection: isExpanded 동적 확장 + staggered 애니메이션 | Components/WordPreviewSection.swift |
| 8 | SessionDetailContentView: 비대칭 패딩 + words 전달 | SessionDetailContentView.swift |
| 9 | SessionTests: words 필드명 변경에 맞춰 테스트 업데이트 | Tests/SessionTests.swift |
| 10 | .mcp.json: shrimp-task-manager 제거 | .mcp.json |

---

## 테스트 계획

| 시나리오 | 유형 | 파일 |
|---|---|---|
| words 배열에 모든 단어 포함 확인 | unit | Projects/Feature/Session/Tests/SessionTests.swift |

---

## 체크리스트

- [x] 계획 수립 완료
- [x] 구현 완료
- [x] 테스트 작성 완료 (test_words_contains_all_words)
- [ ] `bash scripts/verify-task.sh session-detail-ds` PASS
- [ ] 커밋 완료
