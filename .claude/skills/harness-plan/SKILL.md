---
name: harness-plan
description: Use this skill when solving Code Craft implementation problems. It converts a vague feature prompt into a structured plan with requirements, input/output contracts, constraints, responsibilities, SOLID review, and tests. Use before implementation.
---

# harness-plan

## Goal

Convert a vague feature prompt into an implementable and verifiable design plan.

Do not implement code when this skill is first invoked.
Create a plan first.

## Procedure

### 0. Locate the problem definition file

Problem definitions live in `.harness/problems/`, one file per issue:

`.harness/problems/<issue-number-3-digit>-<domain-problem-title>.md`

- `<issue-number-3-digit>` is the GitHub issue number, zero-padded to 3 digits (`#87` → `087`).
- Example: issue `#87` → `.harness/problems/087-어휘검색필터.md`

In the normal flow, this file already exists by the time `harness-plan` runs — the
`setup-worktree` skill creates it (from the GitHub issue) as part of setting up the
worktree, before handing off here. Read it; it is the source of truth for the problem
being solved (this is "the problem file" referenced in step 8). If it does not exist yet
(e.g. `harness-plan` was invoked directly, without going through `setup-worktree` first),
ask the user for the issue number and problem definition before proceeding — do not
invent one.

### 1. Restate the problem

Restate the user request (from the problem definition file) in one sentence.

### 2. List functional requirements

Break the feature into concrete behaviors.

Use action verbs:

- load
- validate
- filter
- aggregate
- calculate
- sort
- return

### 3. List constraints and invalid states

Define what must not be allowed.

Examples:

- invalid input
- hidden data
- unauthorized access
- negative values
- missing IDs
- invalid timestamps

### 4. Identify change points

Identify rules likely to change later.

Examples:

- sorting policy
- visibility policy
- status policy
- pricing policy
- retry policy

### 5. Split responsibilities

Map requirements to code responsibilities.

Format:

Requirement -> Responsibility -> Class or Module

### 6. Apply a short SOLID review

Use these questions:

- SRP: Which class may have more than one reason to change?
- OCP: Which policies should be extendable without changing the service flow?
- LSP: What contract must interchangeable policies follow?
- ISP: Which interfaces should be split?
- DIP: Which concrete dependencies should be injected?

### 7. Propose test cases to cover

These are written after implementation, with the harness-test skill. Include:

- happy path
- empty input
- invalid input
- permission or visibility case
- policy change case
- sorting case

### 8. Label assumptions

If a requirement is not supported by the `.harness/problems/` file from step 0, label it
explicitly as an assumption.

### 9. Write a checklist into the plan file

Every plan must ship with a checklist, written as markdown checkboxes into the task's
`PLAN.md` (`.harness/exec-plans/active/<task-id>/PLAN.md`), broken down from the
responsibilities in step 5 and the test cases in step 7 — one checkbox per concrete step,
not one giant "implement the feature" line.

This checklist is the persistent record of progress. A session can end or restart at any
point; `PLAN.md` on disk, not conversation memory, is what says how far the task got. Check
items off as they're completed instead of leaving that to a separate summary, so a new
session can resume from the file alone.

### 10. Ask for approval

End with:
"Please review this plan before I implement."
