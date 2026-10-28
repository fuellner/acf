# PHP tools and frameworks

Load when a plan or step will name PHP tools. Detect the stack from `composer.json`, the framework bootstrap, and CI. Tools below are examples. Use what the repo already runs. Do not add a tool to the application's Composer files. An analysis tool the application cannot run comes from the isolated toolchain in `toolchain.md`, after the user accepts that run.

## Tools

Read `tool-licenses.md` before naming a tool. A tool that is not listed there is not recommended until its license is added to that file. Commands, phases, and the rule that a failing check stands are in `toolchain.md`.

- **Rector**: mechanical changes. Pick the set that matches the step (a PHP level set for a migration hop, a single rule for a codemod). One set per PR. Read the diff. Rector output is not a behavior proof. Phalcon classes that live in the C extension are invisible without stubs (`phalcon/ide-stubs` or the stubs the repo already has).
- **PHPStan or Psalm**: keep the committed baseline. A step must not add new errors. Do not clear baseline entries as a side effect. If both tools are present, use the one CI runs. Set the language level to the runtime this unit is allowed to use: the target on a migration, the current runtime on a refactor.
- **PHPCompatibility**: a CodeSniffer standard. The 9.3 line stops at PHP 7.4. PHP 8 breaks are found by Rector, PHPStan or Psalm, and the tests. It does not replace the test suite. Details are in `toolchain.md`.
- **Deptrac** (or the boundary tool already in the repo): add a rule when a refactor step introduces a module boundary. Do not map the whole estate in one step.
- **PHPUnit**: characterization and the existing suite. Prefer the repo's current major. Upgrading PHPUnit is a migration step when the runtime forces it, not a refactor side effect.

`composer why-not php <version>` and `composer audit` are migration checks; the upgrade reference says when they are required.

## Frameworks

- **Phalcon**: DI services, magic getters, annotations, and metadata from the extension hide the call graph. Map callers by service name and event hook, not only by static references. Volt views and listeners are part of the behavior. The extension's PHP version coupling is a migration concern; do not "solve" it by rewriting controllers inside a refactor step.
- **Laravel**: facades, the container, Eloquent global scopes, and observers are callers. HTTP feature tests are the usual characterization seam for controllers. Route and config caches are release steps, not code cleanup.
- **Symfony**: the service container and routing maps are the module map. Event subscribers and compiler passes are callers that a "who constructs this class" search misses.
- **No framework**: the public surface is whatever other code includes or calls. Characterize that seam. Do not introduce Laravel, Symfony, or another framework as part of the change.

## What not to mix

A refactor step uses these tools to move code at the current language level. A migration step uses them for the hop's forced fixes. A diff that does both fails the type rule.
