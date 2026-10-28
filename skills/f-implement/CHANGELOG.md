# Changelog

## 2026-10-28
- A **Ticket** line is used as written. A ticket-shaped key found only in the title or body is shown and confirmed once. Common non-ticket prefixes are ignored. The project part is 2–10 characters and starts with a letter.
- Identity is read with `git var GIT_AUTHOR_IDENT` and `git var GIT_COMMITTER_IDENT`. On a public forge, an address that is neither a public mailbox nor that forge's noreply domain is asked once. The identity is never written.
- A dirty tree is listed and carried onto `git switch -c` only after one yes. Nothing is stashed or discarded.
- Worktrees are created only when the task file and test plans are already in the base commit.
- Mode precedence is task, then user, then the handoff default. A conflict is asked.
- Parallel runs leave index rows on each task branch. The main worktree index is not updated.
- Initial creation of f-implement.
- Two modes: `tdd` (failing test, minimal code, refactor, per acceptance criterion) and `direct` (implement, then hand off to f-testing verify).
- One task by default. Several tasks run only when they are independent and the user approves the set. Each of those tasks gets its own worktree and its own `dev/` branch from the same base commit. Worktrees are not removed.
- The dev branch is created only. No commit, no push, no staging, and no change to the git identity. The report suggests a Conventional Commits message per task.
- Branch key: Ticket field, else one ticket-shaped key in the title or body, else the task ID. No tracker call and no invented key.
- Implementation log and append-only handoff under `docs/implement/`. Task status stops at `ready-for-review`.
- An `f-refactor` step is implemented only from that step phase. The feature cycle hands off to `f-testing` and `f-code-review`.
