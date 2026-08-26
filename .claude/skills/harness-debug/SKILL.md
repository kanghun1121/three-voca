---
name: harness-debug
description: Use this skill when a test fails during a Code Craft implementation. It investigates the failing test to identify the responsible module before any code is modified, using a sub-agent to scope the investigation and report findings.
---

# harness-debug

## Goal

When a test fails, do not immediately ask to "fix it."
First identify which responsibility the failing test is related to, and report that scope clearly before touching any code.

## Rules

- Do not modify code before the failing responsibility is identified.
- Do not expand the investigation beyond the failing test's responsibility.
- Do not guess the cause without evidence from the test output or related code.

## Procedure

### 1. Capture the failure

Record:

- which test failed
- the exact assertion or error message
- the expected value vs. the actual value

### 2. Map the failure to a responsibility

Using the responsibility map from harness-plan, identify:

- which class or module owns the failing behavior
- whether the failure belongs to a single responsibility or crosses multiple

### 3. Launch an investigation sub-agent

Use a sub-agent to investigate — do not modify code in this step.

Give the sub-agent:

- the failing test and its assertion
- the responsibility map
- the specific module(s) suspected

Ask the sub-agent to report back:

- the responsibility scope of the failure (which class/module, which reason-to-change)
- whether the failure is a test-intent issue, an implementation bug, or a contract mismatch between policies
- related files that must be touched to fix it
- related files that must NOT be touched (outside the failing responsibility)

### 4. Explain the failing requirement

Before modifying any code, state in plain terms:

- which requirement is not being satisfied
- why the current implementation fails it

### 5. Scope the fix

Based on the sub-agent's report:

- only inspect and modify files tied to the failing responsibility
- do not touch files outside that scope
- do not change the test's intent to make it pass
