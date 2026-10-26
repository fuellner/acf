# Fix Prompt: {{TASK-ID}}

Apply only the following minimal fix. Do not expand scope.

**Findings:**
1. [{{SEVERITY}}] `{{FILE:LINE}}` — Problem / root cause: {{ROOT_CAUSE}} — Proposed fix: {{FIX}}

**Out of scope:**
{{EXPLICIT_LIST_OF_THINGS_NOT_TO_TOUCH}}

**Verification you must perform:**
{{EXACT_VERIFICATION_STEPS_AND_EXPECTED_RESULTS}}

**Status handoff:**
- Set the task to `in-progress` when you start and to `ready-for-review` when done.
- Do not set `done`; that happens in the next review.
- Set `blocked` only when you cannot proceed because a dependency or decision is missing, and record what unblocks the task. Only the user or the implementing agent sets `blocked`.
