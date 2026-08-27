# CLAUDE.md

Scope

Only work inside this repository.

Do not access:

parent directories
home directory
downloads folder
desktop folder
SSH keys
browser data
personal files

Starting From an Issue

When the user hands you a GitHub issue (a number like `#87` or a link), do this immediately,
in order, before anything else:

1. Check the issue (`gh issue view <number>`) to get its title and body.
2. Run the `setup-worktree` skill to create the branch/worktree for it (task-id per the
   Branches rule below) and prepare the Xcode environment.
3. Inside that new worktree, create the problem definition file
   (`.harness/problems/<issue-number-3-digit>-<domain-title>.md`) from the issue content.
4. Only then proceed with Required Workflow below (`harness-plan` first).

Do not write the problem definition file before the worktree exists — it belongs inside
the worktree that will hold the rest of the task's work, not in the main checkout.

If there is no existing issue yet, use the `create-issue` skill instead — it creates the
GitHub issue first, then runs the same setup-worktree flow, leaving the problem definition
file as an empty skeleton for the user to write (do not draft its content yourself).

Required Workflow

For every Code Craft task:

Use the harness-plan skill first.
Define the expected output before implementation.
Define input data models.
Define constraints and edge cases.
Identify change points.
Split responsibilities.
Use the solid-review skill before implementation.
Implement the approved plan.
Write or update tests.
Run tests.
Summarize changed files and verification results.
Rules
Do not implement before creating a plan.
Do not invent production data.
Do not modify files outside this repository.
Do not skip tests.
If tests fail, explain the failing requirement before modifying code again.
Separate test-verified claims from code-inspection-only assumptions in every summary.
When a test fails, only inspect and modify the files related to the failing responsibility.

Branches

When starting a new task, use the `setup-worktree` skill (it creates the branch, worktree,
PLAN.md, and log directory, then prepares the Xcode environment). The `task-id` (which
becomes the branch and worktree name) must follow:

`<issue-number-3-digit>-<type>-<kebab-case-description>`

- `<issue-number-3-digit>` is the GitHub issue number, zero-padded to 3 digits (`#87` → `087`).
- `<type>` is lowercase: feature, fix, refactor, chore, docs.
- Example: issue `#87`, a feature about vocabulary search filter → `087-feature-vocabulary-search-filter`

Commit message and PR conventions (format, type tags, no-emoji rule) live in
`.claude/commands/git/commit.md` and `.claude/commands/git/pr.md` — follow those files
directly instead of duplicating the rules here.
