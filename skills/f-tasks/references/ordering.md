# Task order and parallel groups

Load this reference before writing tasks whenever there is more than one task, any dependency, or a possible parallel split. Apply it before the task documents are written.

## Topological order

- Repeatedly select tasks with no remaining predecessors, order those candidates by priority and ID, emit the next task, and remove it from the remaining graph. Every internal predecessor must appear before its dependents.
- Among tasks whose prerequisites are satisfied, prefer higher priority; break ties by TASK-ID.
- Withhold tasks waiting on open external prerequisites, and their dependents, from the executable order. List them separately with the prerequisite needed to release them.

## Parallel groups

- Derive parallel groups from tasks whose prerequisites are satisfied at the start of that group. Later groups are conditional on completion of preceding prerequisites; do not describe them as runnable now.
- Graph independence is necessary but insufficient: compare `Files to touch` and known shared resources, including fixtures, databases, and generated outputs. Overlapping implementation files or conflicting resources require serial execution by default, or a split into disjoint tasks. If resource isolation is unknown, do not promise conflict-free parallel execution.
- Explain conflicts and the resulting order in the f-tasks report. Keep `parallel-with` out of task documents.
- Coordinate shared status and index updates separately: serialize their integration against the latest contents, preserving other agents' rows. Shared metadata alone need not prevent otherwise independent implementation work.
