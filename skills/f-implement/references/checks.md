# Checks

Load this before calling the implementation finished. The gate is the deterministic checks the project already has. Each acceptance criterion needs its own evidence.

## What runs

Read the task's **Verification** section and the project's existing manifests. Run the test runner, linter, static analyzer, and build that the project already declares. Places those commands are declared include `package.json` scripts, a `Makefile`, `composer.json` scripts, `pyproject.toml`, `Cargo.toml`, and a CI config that names a local command. Use the commands that apply to the files this task touched.

Do not install a package to produce a green run. Do not add a check runner, a linter config, or a test framework the task did not ask for.

A command named in **Verification** is part of the gate.

Every command the step-phase handoff lists under its gate, including toolchain commands copied from the plan or inventory and any parity check, is part of the gate. Run each one in this worktree and record the command and the result. A handoff command that was not run is a failed gate, not a skip. `none named` adds no command.

## Evidence

For every acceptance criterion, record one row:

- the criterion id or its text
- the command that exercised it
- the result: pass, fail, or the assertion line that shows which

In `tdd`, record the failing run and the later passing run. The passing run is the one that counts for the gate. The suite this task is responsible for must be green at the end.

No command exercises the criterion: record `no check`. That is not a pass. Leave the task `in-progress` unless the user, in this session, accepts that gap. Write the acceptance under **Deviations**.

A failing command: leave the task `in-progress`. Do not weaken, skip, or delete the check. Do not edit an assertion to make it pass.

## What the log may contain

Record the command, the exit status, and the relevant assertion line. Do not paste a secret, a credential, or production data. Do not claim a result that was not run in this worktree.
