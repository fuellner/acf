# PHP version upgrade

Load this for every migration plan and every migration step. Do not load it for a pure refactor except to confirm that a requested version bump belongs in a different unit.

## Target

Fetch the current supported-version list from php.net in this session (`https://www.php.net/supported-versions.php`). Record the URL and the retrieval date in the inventory. Use that page, not memory and not this file, for which versions are actively supported or security-only.

Target the latest actively supported PHP 8 release on that page. Do not hardcode a patch level in the plan; name the minor the page lists and pin the patch in the image or lock at execution time from the same page. If the page shows a newer major as the only actively supported line, ask the user before leaving PHP 8. A security-only release is an acceptable temporary production hop only when the user accepts the residual risk. A version absent from both lists is not a production target.

Also record the deployed version from the running image or `php -v`, not only from `composer.json`. `config.platform.php` can lie.

## Order

Security first, among applications in this repository:

1. Internet-exposed and unsupported (on neither list).
2. Internet-exposed and security-only.
3. Sensitive data on an unsupported runtime, including internal apps.
4. Other unsupported runtimes.
5. Actively supported, but behind the target, by exposure and data sensitivity.

Within a tier, prefer hotspots and code the planned work already touches. Do not open a unit for an app that is already on the target. Leave stable modules that are not on the upgrade path out of the step list.

Use P0 for tier 1, P1 for tiers 2 and 3, P2 for the rest that still need work. P3 is rare here; an untouched supported app does not need a unit.

## Interim risk mitigation

Stopgaps while an unsupported runtime remains in production. Record them in the plan. They never satisfy the done criteria.

- Restrict the network: no direct exposure, allowlists, jump hosts for admin paths.
- Put a WAF in front of internet-facing apps.
- Disable extensions and endpoints that production evidence shows are unused.
- Harden the new and, where it is safe, the current `php.ini`: `display_errors` off, `expose_php` off, `allow_url_include` off. Do not copy a loose ini forward.
- Monitor error and access logs for that app.

Do not re-enable removed insecure features to keep old behavior. In particular, do not turn `register_globals` or magic quotes back on and do not emulate them. A script that depended on them gets a narrow forced fix (explicit variables) or an open question when the old input behavior is unclear.

## Hops

Prefer fixes that still run on the current production runtime, one family per PR, then cut production over to a version php.net lists. Do not deploy an unsupported intermediate to production. Intermediate runtimes are for CI and local verification.

Fetch the official migration guide for each hop in this session and treat it as the list of breaks. A large gap uses these boundaries in CI (5.6, then 7.x, then 8.0, 8.1, 8.2, then the fetched target). Production cutover skips any boundary php.net does not list. The families below are the minimum to consider for old code, not a substitute for that guide:

- Through 5.x: magic quotes and `register_globals` are gone by 5.4. Do not bring them back. A `<?` short tag depends on `short_open_tag`.
- Onto 7.0: `mysql_*` and `ereg` are removed. Replace `mysql_*` with mysqli or PDO, not with a new ORM. PHP 4 constructors are deprecated here.
- Through 7.2 and later: `each` and `create_function` are deprecated, and removed in 8.0, together with PHP 4 constructors.
- Onto 8.0: string/number comparisons (`0 == "foo"` and similar), required parameters before optional ones, and engine warnings promoted to errors. Preserving behavior means keeping the observed result. If the new engine makes the old result impossible, stop and raise a question. Do not silently accept the new truthiness.
- Onto 8.1: `null` passed to internal arguments that no longer accept it.
- Onto 8.2: dynamic properties, and string interpolation the guide marks deprecated. `#[AllowDynamicProperties]` or a declared property is a forced fix. Redesigning the object is a follow-up refactor unit.
- Later minors: only what that minor's migration guide, fetched this session, marks as breaking.

`short_open_tag`, default charset, and mysqlnd versus libmysql change behavior. Record the ini and driver diff. Do not flip them as drive-by hardening; charset and short tags are behavior, and a forced driver change follows `database.md` when stored data or query results move.

## Fast path

Use when tests are thin and the gap is more than one major, or when the user asks to reach a supported runtime first.

- Forced fixes only: code that cannot parse or boot on the target, plus deprecations the target CI turns into failures.
- Outer seams only for new oracles (HTTP entry, cron, the queries those hit). Record everything you did not cover.
- Fewest production cutovers. One canary onto the target is enough when backward-compatible fixes have been landing on the old runtime.
- No renames, no type cleanup, no framework replacement, no "while we are here". Each of those is a follow-up refactor unit.

The fast path does not skip a fix the target cannot boot without.

## Tooling

Detect what the repo already runs. Do not add a tool the user has not accepted. Examples, not a required stack:

- Rector: the installed PHP level set for this hop, one rule set per PR. A Rector diff is not proof that behavior held.
- PHPCompatibility (PHP_CodeSniffer) aimed at the target version.
- PHPStan or Psalm with the language level set to the target, existing baseline kept. Do not mass-fix baseline entries.
- `composer why-not php <target>` using the verified target.
- `composer audit` or the repo's equivalent.

Replacing `mysql_*` with mysqli or PDO is forced. Replacing a query layer with an ORM is a refactor unit.

## Frameworks

A framework upgrade that the target PHP requires is part of this migration, following that project's upgrade guide, one guide hop per step. It is not a redesign.

- **Phalcon**: the extension build is tied to the PHP version. If the installed Phalcon cannot load on the target, that upgrade is in this unit only as far as the app still boots and behaves the same. A rewrite off Phalcon is a follow-up refactor, or a blocker question if no supported extension exists. Rector and PHPStan miss extension classes unless stubs are installed.
- **Laravel and Symfony**: follow their upgrade guide hop by hop. Those hops are migration steps. Do not restyle the application because a guide mentions a new API.
- **No framework**: language and runtime only. Do not introduce a framework in this unit.

## Infrastructure

The image, `php.ini`, and extension list move with the app. Local, CI, staging, and production carry the same PHP version, the same extensions (including the Phalcon extension version when that extension is installed), and the same behavior-relevant ini settings. Record them in the inventory. A migration step is not `ready-for-review` until that parity holds for the runtimes the step claims. The agent checks local and CI. Staging needs an approval. Production is the operator's record.

Extend the existing CI so the suite and the golden-master checks run on the production runtime and on the hop target, and diff the normalized output. Drop the old runtime from the required matrix only when production no longer runs it.

Cut over by canary: a slice on the new image, compare errors and the oracles, roll back by redeploying the previous image. The previous image must still work with the schema. If a hop forces a schema or data change, follow the database reference (expand, then contract in a later release).

## Done criteria

A migration unit is not done until all of these are true:

- The app runs on the target recorded from php.net, and the tests and characterization checks pass there.
- Production no longer deploys the old runtime, and CI no longer requires it.
- The dependency audit was run. Remaining findings and any abandoned package that stays are written down with who accepted them.
- A patch cadence is recorded: who applies PHP and dependency security updates, and that CI stays on a php.net-supported version.
- No non-forced structural change landed. Follow-up refactor units are `draft` or `deferred`, not silently dropped.
- Environment parity in the inventory was checked again at close-out: local and CI by the agent, staging and production by an approval or the operator.
- Key pages and jobs named in the inventory have a before and after measurement from CI, approved staging, or the operator. Missing numbers stay open. They are not invented.

## Staying current

The cadence note is the handoff to ordinary maintenance. Do not keep this unit open for future patch releases.
