---
name: f-workflow
description: >
  Presents the feature-cycle skills as an ordered menu. Separates that cycle from
  optional skills (f-docs, f-feature-summary). When a menu item is selected,
  outputs the skill handle plus a ready-to-use prompt template.
  Use only when the user explicitly asks for the skill menu or menu navigation:
  "skill menu", "skill workflow", "workflow menu", "welche skills", "zeige Menü",
  "which skill should I use", "what can I do with these skills", "f-workflow".
  Do NOT trigger on the bare word "workflow" or on workflow-related topics in
  general (CI workflows, workflow engines, process diagrams). Do NOT use for
  executing the actual work of any listed skill (requirements, tasks, testing,
  implementation, review, debug, docs, or feature summaries).
---

# Workflow Menu

Lightweight, agent-agnostic navigation skill for the agentic-coding workflow.
Does not perform domain work. Only displays the menu and supplies prompt templates.

## Behavior

1. Display the menu exactly as structured below.
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
4. **f-implement** — Implement one task on a dev branch. No commit or push unless explicitly requested.  
5. **f-code-review** — Review a diff against acceptance criteria and safety concerns; produce fix prompts.

### Side branch

- **f-debug** — Structured one-pass debugging when something fails (reproduce → root cause → fix proposal). Findings feed back into tasks.

### Optional / Outside Core

- **f-docs** — Generate or refresh project documentation (README, architecture, conventions). `AGENTS.md` only when the repository has none and the user agrees.  
- **f-feature-summary** — Create or update scannable feature summaries (individual units + overall overview) for product owners.

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

### f-implement
```
Please use the f-implement skill on this task. Stay inside the task. Create the dev branch; do not commit or push unless I explicitly ask for it.

Task: [exact ID, such as TASK-001]
Mode: tdd | direct | ask
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
Please use the f-docs skill to analyze the repository and create or update the project documentation (README, architecture, conventions as applicable). Write AGENTS.md only when the repository has none and I agree. Leave an existing AGENTS.md unchanged.

[Optional: specific focus or notes]
```

### f-feature-summary
```
Please use the f-feature-summary skill to create or update scannable feature summaries of the implemented functionality.

Mode: individual units | overview | both
Scope / source: [describe modules, paste description, or point to existing docs/features/]

Prefer tables and structured bullets. Generate individuals first, then the overview if requested.
```

## Rules

- Language: English.
- Keep output short and scannable.
- Always mark the Side branch and Optional section clearly.
- Do not reorder the core cycle. Step 4 is `f-implement`.
- Do not execute any of the listed skills.

## Workflow overview

End every response with this short overview:

- **Cycle:** `f-requirements` → `f-tasks` → `f-testing` → `f-implement` → `f-code-review`
- **Now:** Menu: the workflow menu was shown.
- **Next:** Run the selected skill.

## Before you finish

- The menu is shown exactly as structured, unless behavior step 2 skipped it.
- At most one entry was expanded with handle, role, and prompt template.
- No skill was invoked and no domain work was started.
