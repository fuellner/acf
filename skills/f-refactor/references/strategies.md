# Refactor strategies

Load for a refactor plan or a refactor step. Default to a modular monolith and local refactorings. Choose another strategy only when its condition below is true, and name the choice in the plan.

Do not bump PHP, the framework, or dependencies in a refactor unit. A version you need first is a migration unit.

## Default

**Modular monolith, reached by local refactorings.** Move code behind a boundary inside the same deployable. Enforce the boundary (see `php.md` for Deptrac when the repo is PHP). Extract a service only after that boundary has held through a release. A service extraction in the first step is out of scope; record it as a later unit if the user still wants it.

Each step is one seam: introduce the boundary, move one caller, delete the old path. The system stays releasable after every step. Work on the trunk. Do not open a long-lived branch that lands as one merge.

## When the default does not fit

- **Strangler Fig** — a subsystem must be replaced while the old path still serves production. Route one capability at a time. Delete the old path in a later step of this unit after the new path has been live.
- **Branch by Abstraction** — callers must stay stable while the implementation behind one interface changes. Introduce the interface, switch one caller per step.
- **Parallel run** — the new path is risky enough that production traffic has to be compared before the switch. Run both, record mismatches as bugs (do not "fix" them inside the comparison step unless they are a defect in the parallel harness), then switch and remove the flag. A flag left behind is unfinished work, not a feature.
- **Codemod** — the change is mechanical (a rename the tools can repeat) and does not hide a design change. One rule set per PR, same as a migration batch.

## Steps

A step has one reviewable diff, a rollback (revert the commit or the flag), and a characterization oracle at the seam it touches. Schema work follows `database.md` and is not folded into an unrelated code move.

If a step turns out to need a newer runtime, stop, revert the version change if one started, and open a migration unit.
