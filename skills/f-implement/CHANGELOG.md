# Changelog

## 2026-10-28
- Initial creation of f-implement.
- Two modes: `tdd` (failing test, minimal code, refactor, per acceptance criterion) and `direct` (implement, then hand off to f-testing verify).
- One task by default. Several tasks run only when they are independent and the user approves the set. Each of those tasks gets its own worktree and its own `dev/` branch from the same base commit. Worktrees are not removed.
- The dev branch is created only. No commit, no push, no staging, and no change to the git identity. The report suggests a Conventional Commits message per task.
- Branch key: Ticket field, else one ticket-shaped key in the title or body, else the task ID. No tracker call and no invented key.
- Implementation log and append-only handoff under `docs/implement/`. Task status stops at `ready-for-review`.
- An `f-refactor` step is implemented only from that step phase. The feature cycle hands off to `f-testing` and `f-code-review`.
