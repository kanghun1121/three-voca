---
name: harness-test
description: Use this skill when writing or updating tests for a Code Craft implementation after production code has been written. It defines a standard set of test cases to cover.
---

# harness-test

## Goal

After implementation is complete, cover it with the following tests — but only for the
responsibilities the plan's `PLAN.md` marked as `테스트 필요` in `harness-plan` step 7.
Responsibilities marked `테스트 불필요` are out of scope for this skill; they're verified
by the build check only.

- 정상 케이스 (Happy path)
- 빈 입력 (Empty input)
- 잘못된 입력 (Invalid input)
- 권한 실패 (Permission denied)
- 중복 처리 (Duplicate request)
- 없는 데이터 (Missing data)
- 상태 변경 확인 (State change verification)
- 경계값 (Boundary case)
