# Inventory: {{APP_NAME}}

**Unit**: {{UNIT_ID}}  
**Retrieved**: {{DATE}}  
**PHP support source**: {{URL fetched this session}}

## Runtime

| Item | Value | Evidence |
|------|-------|----------|
| Deployed PHP | {{VERSION}} | {{image tag, php -v, or platform config}} |
| Target PHP | {{VERSION}} | {{actively supported PHP 8 release named by the source above}} |
| Support | {{active \| security-only \| unsupported}} | {{compared with the fetched list}} |
| Extensions | {{LIST}} | {{php -m or image definition}} |
| php.ini notes | {{NOTES}} | {{diffs that change behavior or exposure}} |

## Framework

| Framework | Version | PHP constraint | Notes |
|-----------|---------|----------------|-------|
| {{Phalcon \| Laravel \| Symfony \| none}} | {{VERSION}} | {{CONSTRAINT}} | {{upgrade coupling, or "no framework"}} |

## Dependencies

Checked with the repo's dependency manager. For Composer, record `composer why-not php <target>` and `composer audit` (or state that Composer is not used).

| Package | Constraint | Blocks target | Abandoned | Notes |
|---------|------------|---------------|-----------|-------|
{{DEPENDENCY_ROWS}}

## Entry points

Include cron, CLI scripts, workers, and queue consumers. Web routes alone are not the list. The codebase map does not copy this table.

| Kind | Location | Notes |
|------|----------|-------|
{{ENTRY_ROWS}}

## Environment parity

Same PHP version, extensions (including the Phalcon extension version when Phalcon is installed), and behavior-relevant `php.ini` settings across local, CI, staging, and production. The agent checks local and CI. Staging needs an approval. Production is the operator's record.

| | Local | CI | Staging | Production |
|--|-------|----|---------|------------|
| PHP | {{v}} | {{v}} | {{v}} | {{v}} |
| Extensions | {{list}} | {{list}} | {{list}} | {{list}} |
| Phalcon extension | {{version or "n/a"}} | {{version or "n/a"}} | {{version or "n/a"}} | {{version or "n/a"}} |
| php.ini notes | {{notes}} | {{notes}} | {{notes}} | {{notes}} |
| Evidence | {{how checked}} | {{how checked}} | {{approval or operator}} | {{operator record}} |

## Key pages and jobs

Used for the before/after performance check. Not a production measurement by the agent.

| Name | Kind | Why it matters |
|------|------|----------------|
{{PERF_TARGETS}}

## Exposure

- Internet-facing: {{yes \| no \| unknown}} — {{evidence}}
- Data sensitivity: {{what this app stores or processes, or unknown}}
- Owners: {{names or "unknown"}}

## Tests

- Coverage: {{none \| partial \| solid}} — {{evidence}}
- Can run on the current and target runtimes: {{yes \| no}} — {{how}}

## Priority

{{P0 | P1 | P2 | P3}} — {{one sentence}}

## Effort

{{S \| M \| L \| XL}} — {{one sentence of basis}}
