# Characterization tests

Load before a step edits behavior-bearing code. Coverage is aimed at the seam this step changes. Do not boil the ocean, and do not block a step on modules it does not touch.

## Oracle

Lock observed behavior, including quirks. A test that "corrects" the expected value is a bugfix. Record the bug in the step and assert what the code does now.

Prefer the narrowest oracle that fails when this step changes behavior:

- A unit test around a pure function the step rewrites.
- A golden master or approval test for a rendered page, a report, a serialized payload, or a SQL result set.
- An HTTP or CLI test at the entry point, when that is the seam you can actually run.

`f-testing` writes the test plan and marks these entries `*(characterization)*`. This skill adds the tests only when that plan already names the behaviors. See them pass on the unchanged code before the transformation. If the seam has no such plan and no existing oracle, stop and make `f-testing` the next action.

## After the change

The same tests pass without edited assertions. An assertion edit means the step changed behavior: revert that part, or stop and split the step. Deleting a test is the same as editing it.

On a migration, run the oracle on the current production runtime and on the hop target when the step claims both. A fast-path migration characterizes the outer seams it can run and records the uncovered inner code in the step. Thin inner coverage is acceptable. No oracle at the seam being edited is not.

## What not to characterize

- Proven-dead code you are about to delete. The evidence for deletion is the production trace, not a new test.
- Modules the step does not touch.
- Desired behavior that the code does not have. That is a feature or a bugfix, and it is out of this unit.
