---
name: f-requirements
description: >
  Turns raw software requirements (free text, existing docs, ticket descriptions)
  into structured, agent-friendly requirement documents with strict, checkable
  acceptance criteria. Uses templates for consistent output, supplements missing
  criteria (marked), and maintains an index. Designed for coding agents,
  later task generation, and comparison in code reviews.
  Use when the user wants to capture, normalize, or update requirements,
  acceptance criteria, or feature specs for implementation or review.
  Triggers on: "create requirements", "write acceptance criteria", "turn this into a spec",
  "document this feature", "requirements for the agent", "normalize these ACs".
  Do NOT use for code implementation, code review, or general documentation.
---

# Requirements

Lightweight, agent-agnostic skill that produces consistent requirement documents
so coding agents can implement against them and later reviews can verify them.

## Input

Accept any of the following (provided by the user):

- Free-text description
- Existing markdown or requirements text
- Ticket or issue description (already fetched by the user)
- Explicit request to update an existing REQ document

If a ticket URL or ID is given but no details are present, ask the user once for the content or confirm they will provide it. Do not invent ticket data.

## Workflow

1. Determine whether the request creates a requirement or explicitly updates an existing one:
   - **Create:** collect the IDs from `docs/requirements/*.md` filenames **and** from `docs/requirements/index.md` (union of both), take the highest number and add 1. Start at `REQ-001` when neither exists. Never reuse an ID or overwrite an existing file on creation; check for the same exact ID across both legacy and slugged filenames before writing.
   - **Update:** locate and read the existing document before editing. Use the index as a path hint, then confirm a unique exact-ID match in `docs/requirements/` (`REQ-003.md` or `REQ-003-<slug>.md`, not `REQ-0030`). If the target is missing or ambiguous, ask for clarification rather than creating a replacement. Keep its ID, filename, Created date, and Status; apply any explicit status instruction according to the Status rules below. Do not allocate a new ID or reapply template defaults.
2. Extract requirements and acceptance criteria from the input. On update, merge only the requested changes; preserve unrelated criteria, existing AC identifiers, traceability links, and authored content.
3. Normalize acceptance criteria to the strict format (see below); on update, limit normalization to new or changed criteria. Supplement missing or vague criteria so they are observable and checkable. Mark every supplemented criterion with `*(supplemented)*`.
4. Fill only the sections that contain real content. Remove unfilled placeholders from new or edited sections.
5. For creation, write `docs/requirements/REQ-<id>-<short-slug>.md` using `templates/requirement.md` with initial **Status** `draft`. For an update, edit the resolved file in place and update **Updated** when its content changes.
6. Update `docs/requirements/index.md` (create it from `templates/index.md` if missing), following the index rules below.
7. Report what was created or updated.

Updates to existing documents are allowed only when the user explicitly requests an update (e.g. “update REQ-003” or “add an AC to the signup requirements”) or for the automatic traceability writes: `f-tasks` adds TASK links under `Traceability → Related tasks`, and `f-code-review` appends review paths under `Traceability → Reviews` and updates **Status** per the table below.

## Status

| Status | Meaning | Who sets it |
|--------|---------|-------------|
| `draft` | Captured, not yet agreed | f-requirements on creation |
| `approved` | Agreed and ready for task breakdown | User |
| `done` | Every acceptance criterion passes in review | f-code-review (all AC PASS) |
| `obsolete` | Superseded or dropped | User |

f-tasks and f-testing never change the requirement status. The review sets `done` only when every criterion of that requirement passes.

## Strict Acceptance Criteria

Prefer the Given / When / Then form plus an explicit Check and a Must-not statement.

- One observable result per criterion.
- Always include a concrete Check (command, test name, response field, DOM assertion, exit code).
- Include relevant failure or edge cases.
- State what must not change.
- Mark newly added criteria with `*(supplemented)*`.

For patterns and examples read `references/strict-ac-examples.md` when needed.

## Output Rules

- Language: English.
- Use the templates. Do not invent additional top-level sections.
- Only include a section or constraint bullet when it has content.
- Keep documents focused on one feature / ticket / user story.
- Sequential IDs are stable; store any ticket reference in the Source field.
- Do not implement code. Do not perform reviews.

## Templates

All templates live relative to this skill:

- `templates/requirement.md` — single requirement document
- `templates/index.md` — requirements index

## Documentation Location

Write all output under `docs/requirements/` in the target repository.

Whenever creating or updating documentation under `docs/`, create or refresh `index.md` in each affected directory and every parent below `docs/` (not `docs/` itself), including nested directories. Build missing indexes from all existing contents, not just the current output. List direct documents except the index itself and link child directories through their `index.md` when present, using relative links. Refresh generated entries and remove stale ones while preserving authored prose and established columns. Add child-directory links as a separate list if needed. The requirements index uses `ID | Title | Status | File`. Do not create empty directories just for indexes.

## Before you finish

- Every new or changed acceptance criterion has Given/When/Then, a concrete `Check`, and a `Must not`.
- Every added or rewritten criterion is marked `*(supplemented)*`.
- No unfilled placeholder remains in new or edited sections.
- The document exists at the documented path and the index has a matching row.
- Creation used an unused ID. An update kept the existing ID, path, Created date, Status (unless explicitly changed), and unrelated content and links.
- Every affected documentation directory and parent below `docs/` has an up-to-date `index.md`; entries match existing contents and all generated links resolve.
