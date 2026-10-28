# Tool licenses

Load this when naming a tool, and update it before adding one. Re-check the SPDX id from the GitHub license API (`repos/<owner>/<repo>/license`) or the project's LICENSE file. Do not reuse an id from memory. Set **Last verified** to the date of that check.

**Last verified:** 2026-10-27

This is not legal advice. It does not replace your organization's open-source approval process.

These tools are used at development time. They are not shipped inside the product, so a permissive license or LGPL imposes practically no obligations for that use. The exception is Phalcon: the application may already ship the extension. Packages that Composer installs keep their own licenses. This table does not cover them.

Optional paid add-ons exist, including PHPStan Pro and commercial Rector upgrade services. None of them is required.

| Tool | SPDX | License file | Commercial use |
|------|------|--------------|----------------|
| [Rector](https://github.com/rectorphp/rector) | MIT | [LICENSE](https://github.com/rectorphp/rector/blob/main/LICENSE) | Allowed. Keep the copyright and license notice. |
| [PHPStan](https://github.com/phpstan/phpstan) | MIT | [LICENSE](https://github.com/phpstan/phpstan/blob/2.3.x/LICENSE) | Allowed. Keep the copyright and license notice. |
| [Psalm](https://github.com/vimeo/psalm) | MIT | [LICENSE](https://github.com/vimeo/psalm/blob/master/LICENSE) | Allowed. Keep the copyright and license notice. |
| [Deptrac](https://github.com/opensoftwareconsulting/deptrac) | MIT | [LICENCE.md](https://github.com/opensoftwareconsulting/deptrac/blob/2.0.x/LICENCE.md) | Allowed. Keep the copyright and license notice. Composer package `qossmic/deptrac` is abandoned. |
| [Deptrac (deptrac/deptrac)](https://github.com/deptrac/deptrac) | MIT | [LICENCE.md](https://github.com/deptrac/deptrac/blob/4.x/LICENCE.md) | Allowed. Keep the copyright and license notice. This is the package the isolated toolchain installs. |
| [Composer](https://github.com/composer/composer) | MIT | [LICENSE](https://github.com/composer/composer/blob/main/LICENSE) | Allowed. Keep the copyright and license notice. The tool is dev-time; installed packages are separate. |
| [PHP_CodeSniffer](https://github.com/PHPCSStandards/PHP_CodeSniffer) | BSD-3-Clause | [licence.txt](https://github.com/PHPCSStandards/PHP_CodeSniffer/blob/4.x/licence.txt) | Allowed. Keep the notice. Do not use the authors' names to endorse a product. |
| [PHPUnit](https://github.com/sebastianbergmann/phpunit) | BSD-3-Clause | [LICENSE](https://github.com/sebastianbergmann/phpunit/blob/main/LICENSE) | Allowed. Keep the notice. Do not use the authors' names to endorse a product. |
| [Phalcon (cphalcon)](https://github.com/phalcon/cphalcon) | BSD-3-Clause | [LICENSE.txt](https://github.com/phalcon/cphalcon/blob/master/LICENSE.txt) | Allowed. If the extension is shipped in the product image, keep the license notice with that distribution. |
| [phalcon/ide-stubs](https://github.com/phalcon/ide-stubs) | BSD-3-Clause | [LICENSE.txt](https://github.com/phalcon/ide-stubs/blob/master/LICENSE.txt) | Allowed. Keep the notice. Do not use the authors' names to endorse a product. The GitHub license API returns `NOASSERTION`; the file text is the 3-clause BSD license. |
| [PHPCompatibility](https://github.com/PHPCompatibility/PHPCompatibility) | LGPL-3.0-or-later | [LICENSE](https://github.com/PHPCompatibility/PHPCompatibility/blob/develop/LICENSE) | Allowed. Dev-time use that does not ship the library has no distribution duty. `composer.json` on the develop branch declares `LGPL-3.0-or-later` (checked 2026-10-28). The GitHub license API still returns the deprecated id `LGPL-3.0`. |

Deptrac is the repository GitHub serves for `qossmic/deptrac` (`opensoftwareconsulting/deptrac`). That repository is archived. The maintained Composer package is `deptrac/deptrac` (MIT, checked 2026-10-27). Prefer the boundary tool the target repo already runs when it has one.

The isolated tool project (`scripts/toolchain/composer.json`) only requires these Composer packages. They are not added to the application:

| Composer package | SPDX |
|------------------|------|
| `rector/rector` | MIT |
| `phpstan/phpstan` | MIT |
| `vimeo/psalm` | MIT |
| `deptrac/deptrac` | MIT |
| `squizlabs/php_codesniffer` | BSD-3-Clause |
| `phpcompatibility/php-compatibility` | LGPL-3.0-or-later |
| `phpunit/phpunit` | BSD-3-Clause |
| `phalcon/ide-stubs` | BSD-3-Clause |

## Transitive licenses in the tool lock

Generated from the `license` field of each package in `scripts/toolchain/composer.lock` on 2026-10-28. Direct requirements are in the table above and are not repeated. 55 transitive packages are MIT and 24 are BSD-3-Clause. The other transitive licenses are:

| Package | SPDX |
|---------|------|
| `jetbrains/phpstorm-stubs` | Apache-2.0 |
| `danog/advanced-json-rpc` | ISC |
| `felixfbecker/language-server-protocol` | ISC |
| `netresearch/jsonmapper` | OSL-3.0 |

`netresearch/jsonmapper` is pulled in by Psalm. `jetbrains/phpstorm-stubs` is pulled in by static-analysis packages. These packages are installed only in the tool project. They are not copied into the application and they are not a runtime dependency of the product. That dev-time limit is not legal advice. If a later change vendors them into something that ships, read the license again.

Regenerate this list from the tool project, not from the application:

```bash
composer licenses --working-dir scripts/toolchain --format=json
```

`composer licenses` reads the installed tool tree. The same names are stored on each package in `composer.lock` when the lock is written. Do not invent an SPDX id that the lock does not contain.

## Supply chain

The toolchain installs only the packages in the table above, from exactly one HTTPS Composer source. The default is `https://repo.packagist.org`. An internal repository is allowed only when that tool project disables `packagist.org`. Names were checked on 2026-10-27 against each project's README and the Packagist `repository` field.

- `rector/rector` — `composer require rector/rector --dev` in the Rector README. Repository `github.com/rectorphp/rector`.
- `phpstan/phpstan` — Packagist package linked from the PHPStan README. Repository `github.com/phpstan/phpstan`.
- `vimeo/psalm` — Packagist package linked from the Psalm README. Repository `github.com/vimeo/psalm`.
- `deptrac/deptrac` — `composer require --dev deptrac/deptrac` in the Deptrac README. `qossmic/deptrac` is abandoned on Packagist and is not installed.
- `squizlabs/php_codesniffer` — the name in the PHP_CodeSniffer README (`PHPCSStandards/PHP_CodeSniffer`). `phpcsstandards/php_codesniffer` is abandoned on Packagist and points back at this name. It is not installed.
- `phpcompatibility/php-compatibility` — Packagist package linked from the PHPCompatibility README.
- `phpunit/phpunit` — Packagist package linked from the PHPUnit README. Repository `github.com/sebastianbergmann/phpunit`.
- `phalcon/ide-stubs` — `composer require --dev phalcon/ide-stubs` in that repository's README.

The scripts refuse a second Composer repository, a mirror, `secure-http: false`, and `disable-tls: true`. They refuse a missing tool `composer.lock`. They do not download PHARs and do not add a package that is not in this list. After install they run `composer audit --locked`. The license note above is not legal advice.

## Base image

The tool image is not stored in this repository. `scripts/toolchain/Dockerfile` builds it from two Docker Official Images, both pinned by digest in that file:

- `php` (`php:8.4-cli`), the runtime. It packages PHP under the PHP License and the Debian packages of that image under those packages' own licenses. An Alpine tag is not the default.
- `composer` (`composer:2.8`), used only to copy the Composer binary into the tool image. Composer itself is MIT, listed above.

Docker and Podman are not distributed here. The operator runs an engine they already have. A registry mirror of those two official images is a local choice. It does not change the license of PHP, Debian or Alpine components, or Composer. This note is not legal advice and it does not list every package inside the base image.
