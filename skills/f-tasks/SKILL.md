---
name: f-tasks
description: >
  Turns requirements, ad-hoc descriptions, or code-review findings into
  concrete, agent-sized tasks with complexity rating, model recommendation,
  priority, and explicit dependencies. Produces consistent template-based
  documents so coding agents or subagents can execute them independently.
  Use when converting requirements into implementable tasks, breaking down
  work, planning parallel subagent work, or turning review fixes into tasks.
  Triggers on: "break this into tasks", "create tasks from requirements",
  "task breakdown", "what can run in parallel", "tasks from the review",
  "generate tasks", "task list from REQ".
  Do NOT use for writing requirements themselves, code implementation, or code review.
---

# Tasks

Lightweight, agent-agnostic skill that produces consistent, agent-sized task
documents so coding agents (or subagents) can implement them independently.

## Input

Accept any of the following (provided by the user; do not hard-code tool or MCP calls):

- One or more requirement documents (from `docs/requirements/` or pasted)
- Free-text / ad-hoc description of work
- Code-review findings (from `f-code-review` output or free text)
- Explicit request to update an existing task document

If a source is referenced but content is missing, ask once for it. Do not invent requirements or findings.

## Workflow

1. Determine whether the request creates tasks or explicitly updates existing ones:
   - **Create:** collect the IDs from `docs/tasks/*.md` filenames **and** from `docs/tasks/index.md` (union of both), take the highest number and add 1. Start at `TASK-001` when neither exists. Never reuse an ID or overwrite an existing file on creation; check for the same exact ID across both legacy and slugged filenames before writing.
   - **Update:** locate and read each existing target before editing. Use the index as a path hint, then confirm a unique exact-ID match in `docs/tasks/` (`TASK-003.md` or `TASK-003-<slug>.md`, not `TASK-0030`). If a target is missing or ambiguous, ask for clarification rather than creating a replacement. Keep its ID, filename, Created date, and Status; apply any explicit status instruction according to the Status rules below. Do not allocate a new ID or reapply template defaults.
2. Identify the input type and extract the work items. On update, merge only the requested changes; preserve unrelated criteria, existing AC identifiers, Notes, and verification/traceability links.
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
6. Order tasks topologically. Among tasks whose prerequisites are satisfied, prefer higher priority; break ties by TASK-ID.
   - Repeatedly select tasks with no remaining predecessors, order those candidates by priority and ID, emit the next task, and remove it from the remaining graph. Every internal predecessor must appear before its dependents.
   - Withhold tasks waiting on open external prerequisites, and their dependents, from the executable order; list them separately with the prerequisite needed to release them.
   - Derive parallel groups from tasks whose prerequisites are satisfied at the start of that group. Later groups are conditional on completion of preceding prerequisites; do not describe them as runnable now.
   - Graph independence is necessary but insufficient: compare `Files to touch` and known shared resources, including fixtures, databases, and generated outputs. Overlapping implementation files or conflicting resources require serial execution by default, or a split into disjoint tasks. If resource isolation is unknown, do not promise conflict-free parallel execution.
   - Explain conflicts and the resulting order in the report. Keep `parallel-with` out of task documents. Coordinate shared status/index updates separately: serialize their integration against the latest contents, preserving other agents' rows. Shared metadata alone need not prevent otherwise independent implementation work.
7. For creation, write each task to `docs/tasks/TASK-<id>-<short-slug>.md` using `templates/task.md` with initial **Status** `todo`. For an update, edit the resolved file in place and update **Updated** when its content changes.
   If the source is a requirement, set **Source** to the REQ-ID on creation and add any missing TASK-ID link under Traceability → Related tasks in the requirement document without duplicating existing links.
8. Update `docs/tasks/index.md` (create from `templates/index.md` if missing), following the index rules below. Also maintain the requirement directory's index when adding a traceability link there; do not change requirement status.
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
| `blocked` | Any | Waiting on dependency or decision |

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

## Documentation Location

Write all output under `docs/tasks/` in the target repository.

Whenever creating or updating documentation under `docs/`, create or refresh `index.md` in each affected directory and every parent below `docs/` (not `docs/` itself), including nested directories. Build missing indexes from all existing contents, not just the current output. List direct documents except the index itself and link child directories through their `index.md` when present, using relative links. Refresh generated entries and remove stale ones while preserving authored prose and established columns. Add child-directory links as a separate list if needed. Task indexes use `ID | Title | Priority | Complexity | Status | File`. Do not create empty directories just for indexes. Serialize shared index updates against the latest contents.

## Before you finish

- Every task states a verifiable completion criterion, the files to touch, and its dependencies.
- The dependency graph is acyclic and the reported order is topological; priority only chooses among eligible tasks. Open external prerequisites and waiting dependents are explicit.
- Parallel groups respect prerequisite readiness, implementation-file ownership, and known resource conflicts. Later groups are conditional; shared metadata updates have a serial handoff. No `parallel-with` was stored in the documents.
- Every new task used an unused ID. Updates kept the existing ID, path, Created date, Status (unless explicitly changed), and unrelated content and links. The index has a row per task.
- Every affected documentation directory and parent below `docs/` has an up-to-date `index.md`; entries match existing contents and all generated links resolve.
