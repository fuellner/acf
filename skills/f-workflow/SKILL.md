---
name: f-workflow
description: >
  Presents the available agentic-coding skills as an ordered menu following the
  recommended sequence. Clearly separates the core implementation cycle from
  optional / outside skills (f-docs, f-legal). When a menu item is selected,
  outputs the skill handle plus a ready-to-use prompt template.
  Use only when the user explicitly asks for the skill menu or menu navigation:
  "skill menu", "skill workflow", "workflow menu", "welche skills", "zeige Menü",
  "which skill should I use", "what can I do with these skills", "f-workflow".
  Do NOT trigger on the bare word "workflow" or on workflow-related topics in
  general (CI workflows, workflow engines, process diagrams). Do NOT use for
  executing the actual work of any listed skill (requirements, tasks, testing,
  review, debug, docs, or legal).
---

# Workflow Menu

Lightweight, agent-agnostic navigation skill for the agentic-coding workflow.
Does not perform domain work. Only displays the menu and supplies prompt templates.

## Behavior

1. Display the menu exactly as structured below (Core first, then Optional).
2. If the user has already named a skill or number, skip the menu and jump to the corresponding entry.
3. For the selected entry output:
   - Skill handle (e.g. `f-requirements`)
   - One-sentence role
   - Ready-to-use prompt template (copy-paste ready)
4. Do not invoke or simulate the target skill. Leave that to the user or a subsequent agent.

## Menu

### Core Workflow (normal implementation cycle)

1. **f-requirements** — Capture and normalize requirements into strict, checkable acceptance criteria.  
2. **f-tasks** — Break requirements, ad-hoc work, or review findings into agent-sized tasks.  
3. **f-testing** — Derive concrete test plans from Checks or verify existing coverage.  
4. **Implementation** — Implement the task(s) and the tests from the plan. *(No skill: direct instruction to the coding agent.)*  
5. **f-code-review** — Review a diff against acceptance criteria and safety concerns; produce fix prompts.  
6. **f-debug** — Structured one-pass debugging when something fails (reproduce → root cause → fix proposal).

### Optional / Outside Core

- **f-docs** — Generate or refresh project documentation (AGENTS.md, README, architecture, conventions).  
- **f-legal** — Extract developer-relevant requirements from German/EU legal sources into `docs/legal/`.

## Prompt Templates

### f-requirements
```
Please use the f-requirements skill to turn the following into a structured requirement document with strict, checkable acceptance criteria (Given/When/Then + Check + Must-not). Supplement missing criteria and mark them *(supplemented)*.

[Paste free-text description, ticket, or existing notes here]
```

### f-tasks
```
Please use the f-tasks skill to break the following into agent-sized tasks. Include complexity, priority, dependencies, and parallel groups where relevant.

[Paste requirement document(s), ad-hoc description, or code-review findings here]
```

### f-testing
```
Please use the f-testing skill to generate a test plan from the Check statements of the following acceptance criteria (or verify existing coverage).

Mode: generate | verify
[Paste REQ/TASK document or free text with strict ACs here]
```

### Implementation (no skill)

This step is a direct instruction to the coding agent — there is no `f-` skill for it.

```
Implement the following task(s) exactly as specified. Stay inside the stated scope.

Task document(s): [docs/tasks/TASK-xxx.md or paste]
Acceptance criteria / Checks: [REQ-xxx or paste]
Test plan (if available): [docs/tests/TEST-xxx-plan.md]

Rules:
- Touch only the files listed in the task, plus the status fields and directory indexes described below. Do not refactor, rename, or "improve" surrounding code.
- Implement the tests from the test plan; do not add tests that are not derived from a Check.
- Do not modify acceptance criteria or task documents except the status fields described below.
- If a requirement is ambiguous or the task is not implementable as written, stop and report instead of guessing.

When done: set Status to `ready-for-review`, update `Updated`, and update the row in docs/tasks/index.md.
For every documentation directory created or updated under docs/, refresh index.md by following references/directory-index.md in the installed f-docs skill. Every installed f-* skill links the same file at references/directory-index.md. Use the tasks schema from that file and check that the links resolve.
If the task is `changes-requested`, move it to `in-progress` while you work.
Set `blocked` only when you cannot proceed because a dependency or decision is missing, and record what unblocks the task. Do not set `done` — that happens only after review.
```

### f-code-review
```
Please use the f-code-review skill to review the following change against the linked acceptance criteria. Check for security, performance, and side effects. Deliver precise findings plus a ready-to-use fix prompt.

Diff / commit / branch: [paste or describe]
Acceptance criteria / REQ: [paste or reference]
```

### f-debug
```
Please use the f-debug skill to debug the following issue. Follow the structured process (Reproduce → Isolate Root Cause → Propose Minimal Fix). Produce a Debug Report and optional Fix Prompt. Do not implement the fix.

Issue / error / failing test: [describe]
Relevant context (TASK/REQ, logs, diff): [paste]
```

### f-docs
```
Please use the f-docs skill to analyze the repository and create or update the project documentation (AGENTS.md, README, architecture, conventions as applicable).

[Optional: specific focus or notes]
```

### f-legal
```
Please use the f-legal skill to process the following legal source(s) and extract developer-relevant requirements into docs/legal/.

Source(s): [paste law text, regulation, or link description]
Focus area (optional): [e.g. calculation rules, data retention, …]
```

## Rules

- Language: English.
- Keep output short and scannable.
- Always mark the Optional section clearly.
- Never rename the numbered steps or reorder the core cycle. The only step without a skill handle is **Implementation** — do not invent an `f-implement` / `f-coding` handle for it.
- Do not execute any of the listed skills.

## Before you finish

- The menu is shown exactly as structured (Core first, Optional clearly marked), unless behavior step 2 skipped it.
- At most one entry was expanded with handle, role, and prompt template.
- No skill was invoked and no domain work was started.
