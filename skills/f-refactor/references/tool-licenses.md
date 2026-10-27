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
| [Deptrac (deptrac/deptrac)](https://github.com/deptrac/deptrac) | MIT | [LICENCE.md](https://github.com/deptrac/deptrac/blob/4.x/LICENCE.md) | Allowed. Keep the copyright and license notice. This is the package `scripts/install-tools.sh` installs. |
| [Composer](https://github.com/composer/composer) | MIT | [LICENSE](https://github.com/composer/composer/blob/main/LICENSE) | Allowed. Keep the copyright and license notice. The tool is dev-time; installed packages are separate. |
| [PHP_CodeSniffer](https://github.com/PHPCSStandards/PHP_CodeSniffer) | BSD-3-Clause | [licence.txt](https://github.com/PHPCSStandards/PHP_CodeSniffer/blob/4.x/licence.txt) | Allowed. Keep the notice. Do not use the authors' names to endorse a product. |
| [PHPUnit](https://github.com/sebastianbergmann/phpunit) | BSD-3-Clause | [LICENSE](https://github.com/sebastianbergmann/phpunit/blob/main/LICENSE) | Allowed. Keep the notice. Do not use the authors' names to endorse a product. |
| [Phalcon (cphalcon)](https://github.com/phalcon/cphalcon) | BSD-3-Clause | [LICENSE.txt](https://github.com/phalcon/cphalcon/blob/master/LICENSE.txt) | Allowed. If the extension is shipped in the product image, keep the license notice with that distribution. |
| [phalcon/ide-stubs](https://github.com/phalcon/ide-stubs) | BSD-3-Clause | [LICENSE.txt](https://github.com/phalcon/ide-stubs/blob/master/LICENSE.txt) | Allowed. Keep the notice. Do not use the authors' names to endorse a product. The GitHub license API returns `NOASSERTION`; the file text is the 3-clause BSD license. |
| [PHPCompatibility](https://github.com/PHPCompatibility/PHPCompatibility) | LGPL-3.0 | [LICENSE](https://github.com/PHPCompatibility/PHPCompatibility/blob/develop/LICENSE) | Allowed. Dev-time use that does not ship the library has no distribution duty. |

Deptrac is the repository GitHub serves for `qossmic/deptrac` (`opensoftwareconsulting/deptrac`). That repository is archived. The maintained Composer package is `deptrac/deptrac` (MIT, checked 2026-10-27). Prefer the boundary tool the target repo already runs when it has one.

`scripts/install-tools.sh` only adds these Composer packages, and only under `require-dev`:

| Composer package | SPDX |
|------------------|------|
| `rector/rector` | MIT |
| `phpstan/phpstan` | MIT |
| `vimeo/psalm` | MIT |
| `deptrac/deptrac` | MIT |
| `squizlabs/php_codesniffer` | BSD-3-Clause |
| `phpcompatibility/php-compatibility` | LGPL-3.0 |
| `phpunit/phpunit` | BSD-3-Clause |
| `phalcon/ide-stubs` | BSD-3-Clause |
