# Modes

Load this after the task is resolved and before editing code. The mode is `tdd` or `direct`.

## Where the mode comes from

Precedence is the task, then the user.

1. The task, when a `**Mode**:` line or one sentence states `tdd` or `direct`
2. The user message, when it states `tdd` or `direct`

If both name different modes, ask once and wait. Do not pick one. If neither names a mode, ask once and wait.

## tdd

Take the acceptance criteria in the order written. For each criterion:

1. Add the smallest test that fails because the behavior is absent. Run it. Record the failing command and the failing assertion. The failure must be the missing behavior, not a broken harness.
2. Write the minimum production code that makes that test pass. Run it. Record the passing command and result.
3. Refactor only inside this criterion while that test stays green.

Do not start the next criterion while the suite this criterion introduced is failing. Do not add a test that is not derived from a criterion. Do not skip the failing run.

## direct

Implement the production change the task describes. Do not add a test suite unless the task's acceptance criteria or **Files to touch** include those tests. When the task points at a test plan and says to add those tests, add only those tests.

The project's existing checks still run. After the gate passes, the handoff is `f-testing` in verify mode. That handoff is not a substitute for the gate.

## Both modes

- Stay inside **Files to touch**. Do not edit **Files not to touch**.
- Do not widen the task. A necessary deviation is written under **Deviations** before the extra edit, and the edit waits for the user when it adds a dependency, a migration, a deploy, or a deletion outside the file list.
- Findings that are real but outside the task go under **Follow-ups**. Do not implement them and do not create task files.
