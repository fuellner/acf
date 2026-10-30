# Evals for f-testing

No runner in this repository. A run starts with a fresh context and only this skill. Grade the target repository after the run, not the reply alone.

`evals.json` checks the output. The shape follows the Agent Skills guide for grading output: `prompt`, `expected_output`, `files`, `assertions`. Each assertion has `kind` `structure` or `content`. A case passes only when every assertion passes. A plan that is correct in the reply and missing on disk fails. A heading without the mapped Check fails.

The prompts in cases 1 and 2 do not ask for a file. Case 2 forbids creating files. Case 3 has no `REQ-`, `TASK-`, or `REF-` id. All three require `docs/tests/TEST-<source-id>-plan.md` and a reply that states that path.

Files under `files/` are fixtures. They are not requirements of this repository. In a run they count only because the prompt makes the attached file the only source.
