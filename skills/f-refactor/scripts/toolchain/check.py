#!/usr/bin/env python3
"""Read the tool project without PHP. Used on the host. The image build uses PHP."""
import json
import sys
from urllib.parse import urlparse

PACKAGIST = "https://repo.packagist.org"
ALLOWED = {
    "rector/rector",
    "phpstan/phpstan",
    "vimeo/psalm",
    "deptrac/deptrac",
    "squizlabs/php_codesniffer",
    "phpcompatibility/php-compatibility",
    "phpunit/phpunit",
    "phalcon/ide-stubs",
}
ABANDONED = {
    "phpcsstandards/php_codesniffer": "squizlabs/php_codesniffer",
    "qossmic/deptrac": "deptrac/deptrac",
}


def fail(message):
    print(message, file=sys.stderr)
    raise SystemExit(1)


def load(path):
    try:
        with open(path, encoding="utf-8") as handle:
            data = json.load(handle)
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"could not read JSON: {exc}")
    if not isinstance(data, dict):
        fail("JSON value is not an object")
    return data


def repo_entries(repos):
    if isinstance(repos, list):
        return [(None, value) for value in repos]
    if isinstance(repos, dict):
        return [(str(key), value) for key, value in repos.items()]
    fail("repositories is not an object or list")
    return []


def source_urls(repos):
    disabled = False
    urls = []
    for key, value in repo_entries(repos):
        if key in ("packagist.org", "packagist") and value is False:
            disabled = True
            continue
        if (
            isinstance(value, dict)
            and value.get("packagist.org") is False
            and len(value) == 1
        ):
            disabled = True
            continue
        if (
            isinstance(value, dict)
            and value.get("packagist") is False
            and len(value) == 1
        ):
            disabled = True
            continue
        if not isinstance(value, dict) or "type" not in value or "url" not in value:
            fail("unexpected repository entry")
        if value["type"] != "composer":
            fail("repository type is not composer")
        extra = [item for item in value if item not in ("type", "url")]
        if extra:
            fail("repository entry has extra options")
        urls.append(value["url"])
    return disabled, urls


def cmd_source(expected, path):
    data = load(path)
    config = data.get("config") if isinstance(data.get("config"), dict) else {}
    if "secure-http" in config and config["secure-http"] is not True:
        fail("composer.json config.secure-http is not true")
    if "disable-tls" in config and config["disable-tls"] is not False:
        fail("composer.json config.disable-tls is not false")
    if "repositories" not in data or data["repositories"] is None:
        if expected != PACKAGIST:
            fail("composer.json has no repositories key, so the only source is packagist.org")
        return
    disabled, urls = source_urls(data["repositories"])
    if len(urls) != 1:
        fail("composer.json must declare exactly one Composer source")
    if urls[0] != expected:
        fail("composer.json source does not match the configured URL")
    if expected == PACKAGIST:
        if disabled:
            fail("composer.json disables packagist.org but the configured source is packagist.org")
        return
    if not disabled:
        fail("an internal Composer source must set packagist.org to false")


def cmd_allowlist(path):
    data = load(path)
    require = data.get("require") if isinstance(data.get("require"), dict) else {}
    dev = data.get("require-dev")
    if isinstance(dev, dict) and len(dev) > 0:
        fail("tool composer.json must not use require-dev; direct tools belong in require")
    php = require.get("php")
    if not isinstance(php, str):
        fail("tool composer.json must require php >= 8.4.3")
    import re
    if not re.match(r"^(?:>=8\.4\.(?:[3-9]|[1-9][0-9]+)|\^8\.4(?:\.(?:[3-9]|[1-9][0-9]+))?)$", php.strip()):
        fail(f"tool PHP constraint must be >= 8.4.3 or ^8.4. Got {php}")
    for name, constraint in require.items():
        if name == "php":
            continue
        if not isinstance(name, str) or not isinstance(constraint, str):
            fail("tool requirement is not a string constraint")
        if name in ABANDONED:
            fail(f"refusing abandoned package {name}; the official package is {ABANDONED[name]}")
        if name not in ALLOWED:
            fail(f"package {name} is not on the toolchain allowlist")
        if not re.match(r"^\^[0-9]+\.[0-9]+$", constraint):
            fail(f"constraint for {name} must be ^MAJOR.MINOR")


def cmd_lock(expected, path):
    data = load(path)
    packages = []
    for key in ("packages", "packages-dev"):
        value = data.get(key)
        if isinstance(value, list):
            packages.extend(value)
    host = urlparse(expected).hostname
    internal = expected != PACKAGIST
    if internal and not host:
        fail("configured Composer URL has no host")
    for pkg in packages:
        if not isinstance(pkg, dict):
            fail("composer.lock package entry is not an object")
        for kind in ("dist", "source"):
            block = pkg.get(kind)
            if not isinstance(block, dict) or "url" not in block:
                continue
            url = str(block["url"])
            if not url.startswith("https://"):
                fail(f"composer.lock has a non-https {kind} URL")
        if internal:
            dist = pkg.get("dist")
            if not isinstance(dist, dict) or "url" not in dist:
                fail("composer.lock package has no dist URL for the internal source")
            if urlparse(str(dist["url"])).hostname != host:
                fail(f"composer.lock dist host is not {host}")


def cmd_hash(path):
    data = load(path)
    print(data.get("content-hash") or "")


def cmd_global(expected):
    raw = sys.stdin.read()
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        fail("global repository config is not JSON")
    if not isinstance(data, dict) and not isinstance(data, list):
        fail("global repository config is not JSON")
    disabled, urls = source_urls(data)
    if expected == PACKAGIST:
        if disabled or urls != [PACKAGIST]:
            fail("global Composer config is not packagist.org only")
        return
    only_internal = disabled and urls == [expected]
    only_default = (not disabled) and urls == [PACKAGIST]
    if not only_internal and not only_default:
        fail("global Composer config is not packagist.org only and not the one internal source")


def cmd_rewrite(path, expected):
    data = load(path)
    if expected == PACKAGIST:
        data.pop("repositories", None)
    else:
        data["repositories"] = {
            "packagist.org": False,
            "internal": {"type": "composer", "url": expected},
        }
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(data, handle, indent=4)
        handle.write("\n")


def main(argv):
    if len(argv) < 2:
        fail("usage: check.py <command> ...")
    command = argv[1]
    if command == "source" and len(argv) == 4:
        cmd_source(argv[2], argv[3])
    elif command == "allowlist" and len(argv) == 3:
        cmd_allowlist(argv[2])
    elif command == "lock" and len(argv) == 4:
        cmd_lock(argv[2], argv[3])
    elif command == "hash" and len(argv) == 3:
        cmd_hash(argv[2])
    elif command == "global" and len(argv) == 3:
        cmd_global(argv[2])
    elif command == "rewrite" and len(argv) == 4:
        cmd_rewrite(argv[2], argv[3])
    else:
        fail("usage: check.py source|allowlist|lock|hash|global|rewrite ...")


if __name__ == "__main__":
    main(sys.argv)
