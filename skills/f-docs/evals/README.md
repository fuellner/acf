# Evals for f-docs

No runner in this repository. A run starts with a fresh context and only this skill. Grade the target repository after the run, together with whether the reply asked a question.

`evals.json` checks the output. The shape follows the Agent Skills guide for grading output: `prompt`, `expected_output`, `files`, `assertions`. Each assertion has `kind` `structure` or `content`. A case passes only when every assertion passes.

Files under `files/` are fixtures. They are not documents of this repository. In a run they count only because the prompt says the attached file is already the target `AGENTS.md`.

An existing `AGENTS.md` stays as attached, and the reply does not ask about it. A missing `AGENTS.md` produces a question and no file, until the user agrees. A decline leaves the file absent.
