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

## Exposure

- Internet-facing: {{yes \| no \| unknown}} — {{evidence}}
- Data sensitivity: {{what this app stores or processes, or unknown}}
- Owners: {{names or "unknown"}}

## Tests

- Coverage: {{none \| partial \| solid}} — {{evidence}}
- Can run on the current and target runtimes: {{yes \| no}} — {{how}}

## Priority

{{P0 | P1 | P2 | P3}} — {{one sentence}}
