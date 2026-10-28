# Resume

A later session does not use chat history. Load this when `docs/implement/<TASK-ID>-log.md` already exists or the user asks to continue.

1. Read `docs/implement/index.md`, then the task row in `docs/tasks/index.md`.
2. Resolve one exact task ID with `selection.md`. Several open logs and no ID: ask.
3. Read the newest Handoff entry, then **Plan**, then the task document.
4. Continue the recorded mode, branch, and worktree. Do not create a second branch or a second worktree for the same task.
5. Do not redo the entry's **Do not redo** list.
6. A `changes-requested` task stays on that branch. Move it to `in-progress` while the fix is underway, then back to `ready-for-review` only when the gate passes again.
7. On the way out, append a new handoff entry directly under the Handoff intro. Do not edit older entries.

The worktree path in the newest entry is where the uncommitted change lives. If that path is missing, ask. Do not recreate it and do not remove a different worktree.
