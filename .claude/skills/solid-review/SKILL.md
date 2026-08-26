---
name: solid-review
description: Use this skill before implementing or refactoring a Code Craft solution. It reviews responsibilities, extension points, contracts, interface size, dependencies, and overengineering risk using SOLID principles.
---

# solid-review

## Goal

Review a design before implementation or refactoring.

Do not rewrite code immediately.
First produce a review.

## Review Checklist

### 1. SRP: Single Responsibility

Question:
Which classes or modules have more than one reason to change?

Check:

- validation mixed with business logic
- sorting mixed with aggregation
- data access mixed with response formatting
- policy logic mixed with service orchestration

Output:

- classes with multiple responsibilities
- recommended split

### 2. OCP: Open/Closed

Question:
Which rules may need new implementations later?

Check:

- sorting policy
- visibility policy
- status policy
- ranking policy
- retry policy
- pricing policy

Output:

- policies that should become interfaces or strategy modules
- policies that can stay simple for now

### 3. LSP: Substitution Safety

Question:
Can interchangeable policies be used through the same contract?

Check:

- consistent input
- consistent output
- no hidden mutation
- clear error behavior

Output:

- contract for each policy type

### 4. ISP: Small Interfaces

Question:
Does any interface force unrelated responsibilities?

Check:

- large policy interfaces
- unused methods
- mixed responsibilities

Output:

- smaller interface suggestions

### 5. DIP: Dependency Direction

Question:
Does the service directly create concrete policies?

Check:

- hard-coded concrete classes
- direct construction inside service
- difficulty injecting fake policy for tests

Output:

- dependencies to inject
- dependencies that can remain direct for now

### 6. Overengineering Check

Question:
Is the design larger than the current problem requires?

Check:

- abstractions with only one implementation
- factories without selection logic
- plugin systems without plugin requirements
- unnecessary layers

Output:

- keep now
- defer until needed
- remove from current implementation

## Final Output Format

Return:

- SOLID review summary
- Responsibility map
- Required changes before implementation
- Things that are acceptable to keep simple
- Things to defer
- Test cases needed to verify the design
