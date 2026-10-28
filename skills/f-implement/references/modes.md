# Modes

Load this after the task is resolved and before editing code. The mode is `tdd` or `direct`.

## Where the mode comes from

Precedence is the task, then the user, then the handoff default.

1. The task, when a `**Mode**:` line or one sentence states `tdd` or `direct`
2. The user message, when it states `tdd` or `direct`
3. The step-phase handoff, when it names a mode. A handoff that says `direct` unless the task already states a mode is this default

If two of these name different modes, ask once and wait. Do not pick one. If none names a mode, ask once and wait.

## tdd

Take the acceptance criteria in the order written. For each criterion:

1. Add the smallest test that fails because the behavior is absent. Run it. Record the failing command and the failing assertion. The failure must be the missing behavior, not a broken harness.
2. Write the minimum production code that makes that test pass. Run it. Record the passing command and result.
3. Refactor only inside this criterion while that test stays green.

Do not start the next criterion while the suite this criterion introduced is failing. Do not add a test that is not derived from a criterion. Do not skip the failing run.

## direct

Implement the production change the task describes. Do not add a test suite unless the task's acceptance criteria or **Files to touch** include those tests. When the task points at a test plan and says to add those tests, add only those tests.

The project's existing checks still run. After the gate passes, the feature-cycle handoff is `f-testing` in verify mode. That handoff is not a substitute for the gate.

## Both modes

- Stay inside **Files to touch**. Do not edit **Files not to touch**.
- Do not widen the task. A necessary deviation is written under **Deviations** before the extra edit, and the edit waits for the user when it adds a dependency, a migration, a deploy, or a deletion outside the file list.
- Findings that are real but outside the task go under **Follow-ups**. Do not implement them and do not create task files.

## Step-phase constraints

When the step phase handed the task over, read every reference that handoff names before editing, and run every gate command it lists. The constraints in that handoff are in force. Do not add work the handoff forbids. Typical constraints, when the handoff states them: stay inside the step and its type; tests only from the linked test plan; characterization tests pass before the transformation; no version bump on a refactor; forced fixes only on a migration; record bugs and do not fix them; no dependency change and no deletion without an approval already given; do not edit an assertion or a golden file to hide a behavior change.
