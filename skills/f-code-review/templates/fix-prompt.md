# Fix Prompt: {{TASK-ID or scope}}

Apply only the following open findings. Keep changes minimal; do not expand scope or re-architect.

**Findings:**
1. [{{SEVERITY}}] `{{FILE:LINE}}` — Problem: {{PROBLEM}} — Proposed fix: {{FIX}}

**Out of scope:**
- Refactors, renames, or style changes not required by a finding.
- Anything not listed above.

**Verification you must perform:**
- {{TEST OR COMMAND}}
- Confirm each finding is resolved; do not review the result yourself.

**Status handoff:**
- Set the task to `in-progress` when you start and to `ready-for-review` when done.
- Do not set `done`; that happens in the next review.
