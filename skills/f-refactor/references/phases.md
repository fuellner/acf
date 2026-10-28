# Phases

Load this before running a phase. Run one phase, then stop. Advance **Phase** only when the exit criteria below are met. Procedures for PHP targets, legacy scale, strategies, databases, and oracles stay in their own references. Load those when this file names them.

Create files from the templates. Remove unfilled placeholders and lines that begin with `Instruction:`.

## Inventory

Create the unit when it does not exist. Next id: union of `docs/refactor/REF-*` directories and index ids, plus one, starting at `REF-001`. Never reuse an id. One migration unit is one deployable. One refactor unit is one structural goal.

Load `large-legacy-codebases.md` when the repo is large or legacy. Load `php-version-upgrade.md` before choosing a migration target.

Fill `inventory.md`, including cron, CLI, workers, and other non-web entry points, the parity table, and **Effort**. Start `plan.md` with Type, Phase `inventory`, Effort, and Status `draft`. Sections the plan phase owns may say "Not started."

Parity: the agent may check local and CI. Staging needs an approval. Production values come from the operator. Do not log into production.

**Exit:** the inventory template is filled, Effort is set, and the index row exists. Set Phase to `prioritize` and stop.

## Prioritization

Load `php-version-upgrade.md` for a migration. Set **Priority** and the cross-repo dependency table on the plan. A dependency this session cannot read stays `unknown`; do not invent its status. Defer units that are not starting. Do not start execute while a named dependency is open, unless the user waives it in the handoff.

**Exit:** every unit touched this session has priority, effort, and a dependency row or "none". Set Phase to `safety-net` on units that are not `deferred`.

## Safety net

Write `safety-net.md` from the characterization reference: seams, normalized golden-master fields, and the ban on production data. Emit this prompt and stop. Do not write the test plan.

```
Please use the f-testing skill in generate mode. Lock the current behavior named in the safety-net for this unit. Mark those entries *(characterization)*. Golden masters must normalize the fields listed there. Do not use production or customer data.
```

On a later visit, link the test plan. The fast path may defer inner seams; the safety-net file must say so. The visit that only emits the prompt does not advance Phase.

**Exit:** `safety-net.md` lists the seams and either links a test plan or records an explicit deferral. Set Phase to `plan`.

## Plan

Load `strategies.md` for a refactor, `php-version-upgrade.md` for a migration, and `database.md` when a step will touch schema. Fill the plan: scope, non-goals, done criteria, ordered steps, team, parallel-work rule, and a rollback class on each step (revert, flag, or schema). Each step is one releasable PR of this type only. Split a step that is too big to review here, not during execute.

A feature flag switches the old and new path at runtime and defaults off. Name its owner in the plan, and include a later step of this same unit that removes the flag. Do not add a flag without both. Rollout turns the flag on. Removal is not part of rollout.

Leave Status `draft` until the user accepts. Acceptance sets Status `active`. A draft plan does not advance the phase.

**Exit:** the user has accepted the plan. Set Phase to `execute`.

## Step execution

Refuse a `draft` plan. Refuse when safety-net exit is not met. The step the user names, otherwise the lowest-numbered `in-progress` step, otherwise the lowest-numbered `changes-requested` step, otherwise the lowest-numbered `todo` step. Exactly one.

If that step has no TASK id, emit this prompt and stop. Do not allocate TASK ids.

```
Please use the f-tasks skill on this refactor plan. One task per todo step. Keep the type and the step order. Do not add bugfix tasks.
```

Do not edit application code in this phase. `f-implement` sets the task status. This phase sets the step status.

When the task is `todo` or `changes-requested`, or it is `in-progress` and `docs/implement/<TASK-ID>-log.md` does not exist: set the step to `in-progress`, fill the handoff prompt, and stop. This visit does not meet the exit.

When the task is `in-progress` and the log exists: emit the resume prompt and stop. Do not start a second branch. The resume prompt uses the same references, gate commands, and constraints as the handoff. Its first line is `Please use the f-implement skill. Resume TASK-ID. This invocation is the f-refactor step phase.`

When the task is `blocked`: set the step to `blocked`, record what unblocks it, and stop. Do not emit a review prompt.

When the task is `ready-for-review`: write the step record under `docs/refactor/` from the implementation log and from the plan's rollback class. Include the commands, the results, the revert path, and the production signals. Link the log. Do not paste a diff or a secret. Do not invent a production threshold. Copy recorded bugs onto the step and the plan. Other-type follow-ups become a new `draft` unit, not a fix in this one. Set the step to `ready-for-review`. The agent does not perform the rollback in production. Then emit the review prompt.

Fill Task, Mode, Type, and the gate commands before emitting. Copy each toolchain command this step must pass from the plan and the inventory. Do not invent a command. If none is named, write `none named`.

```
Please use the f-implement skill for this step's task. This invocation is the f-refactor step phase.

Task: TASK-ID
Mode: direct, unless the task already states tdd or direct
Type: migration or refactor, as on the plan

Read these from the f-refactor skill before editing:
- references/characterization-tests.md
- references/toolchain.md. The toolchain is a container, or the same tools outside the application. Run a tool with scripts/toolchain/run.sh. Do not add tools to the application's Composer files. Leave Rector and phpcbf diffs in the report directory. Do not apply that diff.
- Migration: also references/php-version-upgrade.md and references/php.md
- Refactor: also references/strategies.md
- Schema or data: also references/database.md

Gate commands for this step, from the plan and the inventory:
- command

Constraints:
- Stay inside this step and this type. Do not start another step and do not bypass the plan.
- Tests come only from the linked test plan. Characterization tests must pass before the transformation.
- Do not run a database migration or backfill without an approval already recorded for this step.
- Migration: forced fixes only. Parity for the runtimes this step claims must match the inventory before ready-for-review. The agent checks local and CI. Staging and production come only from an approval or the operator.
- Refactor: no version bump.
- Record bugs as follow-ups. Do not fix them. Send other-type work back as a follow-up, not as a code change.
- Deleting code and changing dependencies need an explicit approval.
- Keep the gate commands green. Do not edit assertions or golden files to hide a behavior change. A golden-file change needs a written reason in the implementation log.
- Do not commit, push, or set done. Do not edit docs/refactor/.
```

```
Please use the f-code-review skill. This change is an f-refactor unit. Type: migration or refactor, as on the plan. Apply the behavior-preservation check. A golden-master change needs the reason on the step record.
```

**Exit:** one step is `ready-for-review` or `blocked`, and the review prompt was emitted when the step is `ready-for-review`. A visit that only emits an `f-implement` prompt does not meet this exit. Stay on Phase `execute` until every step is `done` or `skipped`, then set Phase to `rollout`.

## Rollout

Write `rollout.md`. Name the operator, who is notified, the canary, and the signals copied from the steps. List which guardrails this rollout hits. Do not deploy, and do not touch production. If the operator reports that a signal fired, record it and emit the debug prompt. Do not patch forward.

When the plan uses a feature flag, the rollout record names the flag, its owner, that it defaults off, and the step that removes it. The operator turns the flag on. The agent does not change the flag in production. Removing the flag stays a later step of this unit.

```
Please use the f-debug skill. The failure is inside this f-refactor unit and step. Stay inside that type. Do not propose a redesign or a version bump the type forbids. Use only logs and errors the user pasted.
```

**Exit:** the rollout record is filled. Set Phase to `close-out` only after the operator reports the rollout finished or explicitly skipped for a change that is not yet shipping. A skipped rollout says why.

## Close-out

Fill `close-out.md` from the plan's done criteria. For a migration, include the checklist in `php-version-upgrade.md`: target runtime, audit, parity, and before/after performance of the key pages and jobs named in the inventory. Performance numbers come from CI, an approved staging run, or the operator. Do not measure production yourself and do not invent timings.

Emit `f-docs` when a boundary decision should become an ADR. Link the ADR from `decisions.md`. Do not write `docs/decisions/` here.

```
Please use the f-docs skill to record the architecture decision named in this unit's decisions log. Leave docs/refactor/ unchanged.
```

Closing the unit is a review, not this phase:

```
Please use the f-code-review skill to close this f-refactor unit. Confirm every step is done or skipped and check each done criterion, including parity and performance for a migration.
```

**Exit:** `close-out.md` is filled and the close prompt was emitted. Leave Status unchanged. Phase stays `close-out` until `f-code-review` or the user sets `done`.

## Feature or bugfix

Not a phase. Record the bug or the follow-up on the plan, then emit:

```
Please use the f-workflow skill. This is a feature or a bugfix, outside the migration or refactor unit.

Unit: REF-id
Item: [description, with no secrets or customer data]
```
