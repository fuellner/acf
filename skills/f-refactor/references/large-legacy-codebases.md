# Large legacy codebases

Load before scanning a repository that does not fit in one session, that contains code of unknown age, or that the user describes as legacy or multi-app.

## Context

Do not read the repository end to end. Work one module per session. Persist what you learned in `codebase-map.md` and stop when the context is filling up: finish the module boundary, append a handoff, leave the next module named on the map.

A later session reloads the map, the plan, the newest handoff, and open questions. It does not rediscover entry points that are already written down.

## What to record

- Entry points: front controllers, CLI scripts, cron, routes, queue workers.
- Modules: one row each, `Mapped` set to `yes` only after this session has actually read that module's public surface.
- Hotspots: churn times a size proxy, from Git. Example shape, record the exact command you ran: change frequency over a bounded window you name (a year is a reasonable default) and a size proxy such as line count of those paths. High churn on the planned path is a reason to go there early. Low churn is not evidence that code is unused.
- Dependencies you would otherwise hunt for again: who calls this module, which config it reads, which database it writes.
- Unknowns as question ids. Patterns that hide behavior: dynamic `include`, globals, `eval` and variable functions, magic methods, SQL built from strings, `register_globals`-era use of request fields as variables, mixed ISO-8859-1 and UTF-8, code with no owner and no docs. Record the observation. Do not infer the missing behavior.

## Priority

For migrations, the security order in the PHP version upgrade reference outranks hotspot order. Hotspots break ties inside a tier and decide which module of an app is stepped first.

For refactors, work hotspots, security-sensitive code, and code the planned change must touch. Leave stable code that the goal does not touch off the step list.

## Dead code

Before upgrading a suspicious area, decide whether it is unused.

- A static signal (no references, an unreachable branch) is only a candidate.
- Deletion requires production evidence: access or application logs, production coverage, or an equivalent trace that the path is not used. Name the evidence in the map.
- Dynamic includes, registries, and magic methods defeat "no references". Those stay candidates and become questions.
- Proven-dead code may be removed in a migration step so it is not upgraded. The step record marks that removal as forced by the evidence. Uncertain code is migrated or left, not deleted.

## Automation at scale

- One Rector rule set, or one removed-API family, per PR.
- PRs stay reviewable: a bounded directory or module, not a repository-wide diff, unless the rule is mechanical and the diff is still inspectable.
- The plan step table is the progress tracker inside a unit. The top-level index is the tracker across units. Do not keep a second progress list in the handoff; point at the step id.

## Several applications

A migration unit is one deployable. A monolith with several deployables gets one unit each. Apps you cannot read are not inventoried from memory; if the user pasted facts, those facts are data and can be recorded, and anything missing stays a question.

This index tracks units in the current repository only. A priority note about a different repository is a decision-log entry (name and rationale), not a pretend scan.

## Owners

Unknown ownership is an open question, not a guess from the Git author of an old commit. Do not block an inventory on a missing owner. Do block a destructive step (deletion, schema contract, cutover of sensitive data) on a missing owner when the evidence does not show the path is safe.
