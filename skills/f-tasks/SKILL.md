---
name: f-tasks
description: >
  Turns requirements, ad-hoc descriptions, code-review findings, or refactor
  plans into concrete, agent-sized tasks with complexity rating, model
  recommendation, priority, and explicit dependencies. Produces consistent
  template-based documents so coding agents or subagents can execute them
  independently.
  Use when converting requirements into implementable tasks, breaking down
  work, planning parallel subagent work, turning review fixes into tasks,
  or turning a migration or refactor plan into tasks.
  Triggers on: "break this into tasks", "create tasks from requirements",
  "task breakdown", "what can run in parallel", "tasks from the review",
  "generate tasks", "task list from REQ", "tasks from the refactor plan",
  "tasks from the migration".
  Do NOT use for writing requirements themselves, code implementation,
  executing a migration or refactor step, or code review.
---

# Tasks

Lightweight, agent-agnostic skill that produces consistent, agent-sized task
documents so coding agents (or subagents) can implement them independently.

## Input

Accept any of the following (provided by the user; do not hard-code tool or MCP calls):

- One or more requirement documents (from `docs/requirements/` or pasted)
- Free-text / ad-hoc description of work
- Code-review findings (from `f-code-review` output or free text)
- A refactor unit plan (`docs/refactor/REF-*/plan.md`, or the same shape pasted)
- Explicit request to update an existing task document

If a source is referenced but content is missing, ask once for it. Do not invent requirements or findings.

## Workflow

1. Determine whether the request creates tasks or explicitly updates existing ones:
   - **Create:** collect the IDs from `docs/tasks/*.md` filenames **and** from `docs/tasks/index.md` (union of both), take the highest number and add 1. Start at `TASK-001` when neither exists. Never reuse an ID or overwrite an existing file on creation; check for the same exact ID across both legacy and slugged filenames before writing.
   - **Update:** locate and read each existing target before editing. Use the index as a path hint, then confirm a unique exact-ID match in `docs/tasks/` (`TASK-003.md` or `TASK-003-<slug>.md`, not `TASK-0030`). If a target is missing or ambiguous, ask for clarification rather than creating a replacement. Keep its ID, filename, Created date, and Status; apply any explicit status instruction according to the Status rules below. Do not allocate a new ID or reapply template defaults.
2. Identify the input type and extract the work items. On update, merge only the requested changes; preserve unrelated criteria, existing AC identifiers, Notes, and verification/traceability links.
   When the input contains a requirement document, read its **Status** before decomposing it. `approved` is ready for task breakdown. If the status is `draft`, warn that it is not agreed and ask whether to proceed. Stop until the user confirms. If work continues, repeat the warning in the report. Do not change the requirement status.
3. Decompose new work into agent-sized tasks; for updates, apply these sizing rules to the requested changes without replacing existing tasks. Each task must:
   - Have one clear goal and one primary output type
   - List concrete files to touch (and files not to touch when relevant)
   - Include verifiable acceptance criteria or a verification step
   - Fit comfortably in a single agent session
4. For new tasks assign the fields below; on update, revise them only as needed for the requested change:
   - Priority (P0–P3)
   - Complexity (XS / S / M / L; split XL)
   - Model recommendation (tier + reasoning level)
   - Dependencies as one machine-readable line: `blocked-by: TASK-003, TASK-007 | blocks: TASK-009`, or `none`. Do not store `parallel-with` — derive it from the graph.
5. Validate the dependency graph before writing anything:
   - Follow every `blocked-by` chain to its roots. Reaching the same task twice on the same active path is a cycle; shared ancestors on separate paths are not.
   - On a cycle, do not write it. Merge the tasks, drop the weaker edge, or extract the shared work into its own task.
   - Identify existing prerequisites outside the new task set and read their status. Only `done` satisfies an existing prerequisite; an open, missing, or unknown external dependency must be reported as waiting, not treated as satisfied.
6. Read `references/ordering.md` and apply it before writing whenever there is more than one task, any dependency, or a possible parallel split. It defines topological order, priority among eligible tasks, withheld external prerequisites, parallel groups, and the serial handoff for shared index updates. A single independent task needs no parallel-group report.
7. For creation, write each task to `docs/tasks/TASK-<id>-<short-slug>.md` using `templates/task.md` with initial **Status** `todo`. For an update, edit the resolved file in place and update **Updated** when its content changes. Remove every unfilled `{{...}}` placeholder. Omit optional sections that have no content, including `Files not to touch` and `Notes`.
   If the source is a requirement, set **Source** to the REQ-ID on creation and add any missing TASK-ID link under Traceability → Related tasks in the requirement document without duplicating existing links.
   If the source is a refactor plan, create one task per step whose status is `todo`. Do not merge steps, do not split a step, and do not add tasks for recorded bugs or for the other type. If a step is too large for one session, stop and send it back to `f-refactor` instead of writing a partial task. Set **Source** to the step id and type (`REF-001-S01`, `migration` or `refactor`). Dependencies follow the step order. In **Verification** and **Notes**, require `f-refactor` step mode: preserve behavior, and stay inside the type. Write the TASK id into that step's Task cell and update the plan's **Updated** field. Do not change the step's status.
8. Update `docs/tasks/index.md` (create from `templates/index.md` if missing), following `references/directory-index.md`. Also maintain the requirement directory's index when adding a traceability link there; do not change requirement status. When a refactor plan's Task cell changes, maintain that unit's index and `docs/refactor/index.md`; do not change the unit's status.
9. Report the created or updated tasks, their priorities, dependency order, and which tasks can run in parallel.
   Name waiting external prerequisites, shared-resource conflicts, and who will serialize shared metadata updates before parallel work starts.
   If the graph was resolved (cycle broken, tasks merged), say so explicitly.

Updates to existing task documents are allowed only when the user explicitly requests an update, when an implementing agent sets status after finishing work, or when f-code-review updates status after a review (see Status below).

## Status

A task is only `done` after a positive review and when it is merge-ready (or already merged).
The implementing agent must not set `done`.

| Status | Who sets | Meaning |
|--------|----------|---------|
| `todo` | Skill on creation | Not started |
| `in-progress` | Implementing agent | Work has started |
| `ready-for-review` | Implementing agent | Implementation and local verification finished; review pending |
| `changes-requested` | f-code-review | Review found blocking findings; a fix prompt was issued |
| `done` | f-code-review (APPROVED) or explicit user request | Review passed, merge-ready or merged |
| `blocked` | User or implementing agent | Waiting on a dependency or decision |

Only the user or the implementing agent sets `blocked`. `f-code-review` and `f-debug` may recommend it and must not set it.

When an implementing agent finishes a task it must:
1. Set **Status** to `ready-for-review`
2. Update the **Updated** field
3. Update the corresponding row in `docs/tasks/index.md`

These steps are also stated in the task template (`templates/task.md`) so the implementing agent sees them directly in the document.

Do not set `done` here. `done` is set by `f-code-review` when the verdict is APPROVED, or when the user explicitly confirms it.
After a review set the task to `changes-requested`, the implementing agent moves it to `in-progress` while fixing and back to `ready-for-review` when the fix and verification are complete.

## Agent-Sized Rules

Prefer vertical slices over pure horizontal layers when the feature allows it.
Order by dependency: data model before logic, logic before API, API before UI.
Each task should leave the system in a coherent state.

## Complexity and Model Recommendation

| Complexity | Typical size                  | Model tier     | Reasoning |
|------------|-------------------------------|----------------|-----------|
| XS         | 1 file, single function       | fast/cheap     | low       |
| S          | 1–2 files, local change       | fast or mid    | low       |
| M          | 3–5 files, one feature slice  | mid-tier       | medium    |
| L          | multi-file, decisions needed  | strong         | high      |
| XL         | too large — split further     | —              | —         |

Recommendation is guidance only. Prefer the smallest model that can reliably complete the task. See `references/complexity-examples.md` for calibration.

## Priority

- **P0**: blocking, critical path, security, or production fix
- **P1**: high business value or unblocks others
- **P2**: normal feature work
- **P3**: nice-to-have or cleanup

## Ad-hoc and Review Inputs

- **Ad-hoc**: Mark source as `ad-hoc`. Keep tasks small. Note that they can later be promoted to requirements if they grow.
- **Review fixes**: Mark source as `review` (optionally with finding ID). Link to original REQ if known. Prefer focused, small fix tasks with elevated priority.
- **Refactor plans**: The plan's step boundaries, order, type, and non-goals are the scope. Recorded bugs stay recorded unless the user explicitly asks for a separate fix, and that fix is not part of the refactor unit.

## Output Rules

- Language: English.
- Use the templates. Do not invent additional top-level sections.
- Only include a section when it has content.
- Sequential IDs are stable.
- Do not implement code. Do not perform reviews.

## Templates

All templates live relative to this skill:

- `templates/task.md` — single task document
- `templates/index.md` — tasks index

## References

- `references/ordering.md` — topological order and parallel groups. Load it from workflow step 6.
- `references/directory-index.md` — shared `index.md` rules.
- `references/complexity-examples.md` — calibration for the complexity table.

## Documentation Location

Write all output under `docs/tasks/` in the target repository.

Follow `references/directory-index.md` whenever creating or updating documentation under `docs/`. Serialize shared index updates against the latest contents.

## Before you finish

- Every task states a verifiable completion criterion, the files to touch, and its dependencies.
- The dependency graph is acyclic. Where step 6 applies, the reported order follows `references/ordering.md`. Open external prerequisites and waiting dependents are explicit.
- Any parallel grouping follows `references/ordering.md`: prerequisite readiness, file and resource conflicts, conditional later groups, and a serial handoff for shared metadata. No `parallel-with` was stored in the documents.
- No unfilled `{{...}}` placeholder remains. Empty optional sections are removed.
- Requirement sources in `draft` were not broken down without an explicit confirmation. The report repeats that warning when tasks were still written.
- Every new task used an unused ID. Updates kept the existing ID, path, Created date, Status (unless explicitly changed), and unrelated content and links. The index has a row per task.
- A refactor plan used as input has one task per `todo` step, and each of those steps links that task. No step was merged, split, or given a bugfix task.
- Every affected documentation directory and parent below `docs/` has an up-to-date `index.md` per `references/directory-index.md`; entries match existing contents and all generated links resolve.
