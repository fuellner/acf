# Task selection

Load this before choosing work. Ask instead of guessing. The default is one task.

## Resolve one ID

1. Read `docs/tasks/index.md` as a path hint only.
2. List `docs/tasks/` for the exact ID. `TASK-001.md` and `TASK-001-<slug>.md` match `TASK-001`. `TASK-0010` does not.
3. No file, or more than one file: ask once. Do not create a task and do not pick a file.
4. Read the matched file.

There is no task index and no ID in the request: ask for the ID. Do not choose a task because it looks next.

## Status

| Status | Action |
|--------|--------|
| `todo` | Start |
| `in-progress` | Resume. Load `resume.md`. Do not start a second branch |
| `changes-requested` | Start the fix on the existing branch |
| `ready-for-review` | Ask. Do not start another implementation |
| `done` | Ask. Do not start |
| `blocked` | Ask. Do not start. The unblock condition stays in the task |

## Refactor and migration sources

**Source** that contains a step id `REF-<digits>-S<digits>` is an `f-refactor` step.

Implement it only when the user message is the step-phase handoff (it names the `f-refactor` step phase and this task). Otherwise stop and emit:

```
Please use the f-refactor skill. Resume <REF-id> at step execution for <step id>.
```

Resolve the unit the same way the step id is written: `REF-001` matches `REF-001-<slug>/`, not `REF-0010`. Use the index row, then `plan.md`. If you find the plan and its **Status** is not `active`, stop. If you cannot find the plan, continue only when the handoff says the step phase already accepted it. Do not edit `docs/refactor/`.

## More than one task

Naming several IDs is not approval to run them. Show the set, say whether it is independent, and wait for an explicit approval of that set.

A set is independent when all of the following hold:

- Every selected status is `todo`, `in-progress`, or `changes-requested`.
- No selected task lists another selected task in `blocked-by`, including through a chain inside the set.
- **Files to touch** do not overlap. A selected task with no file list is not independent; ask.
- Every `blocked-by` predecessor outside the set is `done`.

`blocked` tasks are not in the set. Mutual dependencies are not independent.

When the set fails these rules, do not start it. Name the rule that failed and ask which one task to run.

When the user approves an independent set:

- One git worktree and one `dev/` branch per task, all from the same base commit. See `git.md`.
- When the runtime can delegate each worktree to its own agent, do that.
- When it cannot, implement one worktree after another.
- Do not check out one branch in two worktrees.
- Do not remove a worktree, delete its directory, or merge the branches.
- Each worktree updates indexes only on its own branch. The main worktree's index is not updated. When those branches are later merged, expect conflicts in `docs/tasks/index.md` and `docs/implement/index.md`. Keep both rows.

One agent edits one worktree. Each worktree updates its own copy of the task file, the implementation log, and the indexes. Do not merge those copies. The report lists the intended status of each task.
