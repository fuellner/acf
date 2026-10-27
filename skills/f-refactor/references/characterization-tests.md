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

## Golden masters

Use a golden master when the seam's output is a page, a report, a payload, or a result set. Before comparing, normalize nondeterministic fields to a fixed stand-in: timestamps, generated ids, session tokens, and random values. Record those fields in `safety-net.md`. Anything else that moves between runs gets the same treatment. A diff on a normalized field is a behavior change, not a reason to regenerate the file.

Golden files are versioned with the tests. Updating one requires a reason on the step record: what changed in the output and why it is still the same behavior, or why the user accepted a difference. Do not refresh a snapshot to make a step pass. `f-code-review` treats a silent refresh as a finding.

For a migration, run the same suite under the old runtime and the target runtime and diff the normalized output. A PHP comparison change that shows up only in that diff stops the step.

Fixtures are anonymized or synthesized. No production rows, no customer payloads, no secrets copied out of config or the database.

## What not to characterize

- Proven-dead code you are about to delete. The evidence for deletion is the production trace, not a new test.
- Modules the step does not touch.
- Desired behavior that the code does not have. That is a feature or a bugfix, and it is out of this unit.
