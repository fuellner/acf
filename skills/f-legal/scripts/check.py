#!/usr/bin/env python3
"""Mechanical checks for f-legal Markdown files. Python standard library only.

Usage:
  python3 scripts/check.py [--markdown] FILE...
  python3 scripts/check.py --self-test

Exit 0 when every check passes. A failing check is printed as
file, check, fail, detail. With --markdown the same results are a table.
"""

from __future__ import annotations

import argparse
import re
import sys
import tempfile
from pathlib import Path

ISO = re.compile(r"^\d{4}-\d{2}-\d{2}$")
QID = re.compile(r"\[Q(\d+)\]")
SECTION = re.compile(r"^## Rechtslage zum Stichtag (\d{2})\.(\d{2})\.(\d{4})$")
CHRON = re.compile(r"^### (\d{4}-\d{2}-\d{2}) – \S")
GILT = re.compile(r"^Gilt bis: (\d{4}-\d{2}-\d{2}|unbefristet)$")
PARA = re.compile(r"§")
BARE_NUMBER = re.compile(r"^\d+(?:[.,]\d+)?$")
ONE_Q = re.compile(r"^\[Q\d+\]$")

SUBJECT_KEYS = (
    "titel",
    "bereich",
    "gegenstand",
    "rechtsraum",
    "stichtag",
    "stand_recherche",
    "rechtsstand",
    "berechnung",
    "rechtsgrundlagen",
    "aenderungen_geprueft_bis",
)
OVERVIEW_KEYS = ("titel", "bereich", "rechtsraum", "stichtag", "stand_recherche")
SUBJECT_HEADS = (
    "Kurzüberblick",
    "Rechtslage zum Stichtag",
    "Änderungen ab Stichtag",
    "Quellen",
)


def parse_front_matter(text: str) -> tuple[dict, str]:
    if not text.startswith("---\n"):
        raise ValueError("Kopf fehlt")
    end = text.find("\n---\n", 4)
    if end < 0:
        raise ValueError("Kopf nicht geschlossen")
    raw = text[4:end]
    body = text[end + 5 :]
    data: dict = {}
    current = None
    for line in raw.splitlines():
        if not line.strip():
            continue
        item = re.match(r"^\s+-\s+(.*)$", line)
        if item and current:
            value = item.group(1).strip().strip("\"'")
            data.setdefault(current, [])
            if not isinstance(data[current], list):
                data[current] = []
            data[current].append(value)
            continue
        field = re.match(r"^([A-Za-z0-9_]+):\s*(.*)$", line)
        if not field:
            continue
        key, value = field.group(1), field.group(2).strip()
        current = key
        if value.startswith("[") and value.endswith("]"):
            inner = value[1:-1].strip()
            data[key] = (
                []
                if not inner
                else [part.strip().strip("\"'") for part in inner.split(",")]
            )
        elif value == "":
            data[key] = []
        else:
            data[key] = value.strip("\"'")
    return data, body


def h2(body: str) -> list[str]:
    return [line[3:].strip() for line in body.splitlines() if line.startswith("## ")]


def split_h2(body: str) -> list[tuple[str, str]]:
    parts: list[tuple[str, str]] = []
    name = None
    buf: list[str] = []
    for line in body.splitlines():
        if line.startswith("## "):
            if name is not None:
                parts.append((name, "\n".join(buf)))
            name = line[3:].strip()
            buf = []
        elif name is not None:
            buf.append(line)
    if name is not None:
        parts.append((name, "\n".join(buf)))
    return parts


def table_rows(section: str) -> list[list[str]]:
    rows = []
    for line in section.splitlines():
        if not line.strip().startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if set("".join(cells)) <= set("-: "):
            continue
        rows.append(cells)
    return rows


def blank_lines_before_tables(body: str) -> list[str]:
    lines = body.splitlines()
    problems = []
    for index, line in enumerate(lines):
        if not line.startswith("|"):
            continue
        previous = lines[index - 1] if index else ""
        if previous.startswith("|"):
            continue
        if previous.strip() != "":
            problems.append(line[:60])
    return problems


def tables(section: str) -> list[list[list[str]]]:
    groups: list[list[list[str]]] = []
    current: list[list[str]] = []
    for line in section.splitlines():
        if not line.strip().startswith("|"):
            if current:
                groups.append(current)
                current = []
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if set("".join(cells)) <= set("-: "):
            continue
        current.append(cells)
    if current:
        groups.append(current)
    return groups


def norm_value(cell: str) -> str:
    text = re.sub(r"\s+", " ", cell.strip().lower())
    text = re.sub(r"^höchstens die\s+", "", text)
    text = re.sub(r"^höchstens\s+", "", text)
    text = re.sub(r"\s+je\b.*$", "", text)
    return text.strip(" .")


def is_amount(cell: str) -> bool:
    text = norm_value(cell)
    return bool(text) and text not in {"keine", "keiner", "—", "-", "–"} and bool(re.search(r"\d", text))


def column_amounts(section: str, column: str) -> list[str]:
    found = []
    for table in tables(section):
        if not table or column not in table[0]:
            continue
        index = table[0].index(column)
        for row in table[1:]:
            if len(row) > index and is_amount(row[index]):
                found.append(norm_value(row[index]))
    return found


def source_ids(section: str) -> list[str]:
    found = []
    for row in table_rows(section):
        if row and re.fullmatch(r"Q\d+", row[0]):
            found.append(row[0])
    return found


def check_file(path: Path) -> list[tuple[str, str, str]]:
    """Return (check, result, detail) rows. result is ok or fail."""
    checks: list[tuple[str, str, str]] = []

    def add(check: str, ok: bool, detail: str = "") -> None:
        checks.append((check, "ok" if ok else "fail", detail))

    try:
        text = path.read_text(encoding="utf-8")
        meta, body = parse_front_matter(text)
    except (OSError, ValueError) as exc:
        add("kopf", False, str(exc))
        return checks

    overview = path.name == "uebersicht.md"
    keys = OVERVIEW_KEYS if overview else SUBJECT_KEYS
    missing = [key for key in keys if key not in meta or meta[key] in ("", [])]
    add("kopf", not missing, "fehlt: " + ", ".join(missing) if missing else "")
    if missing:
        return checks

    add("rechtsraum", meta.get("rechtsraum") == "DE", str(meta.get("rechtsraum")))
    stichtag = str(meta.get("stichtag", ""))
    add("stichtag", bool(ISO.match(stichtag)), stichtag)
    if not overview:
        for key in ("stand_recherche", "rechtsstand", "aenderungen_geprueft_bis"):
            value = str(meta.get(key, ""))
            add(key, bool(ISO.match(value)), value)
        searched = str(meta.get("aenderungen_geprueft_bis", ""))
        researched = str(meta.get("stand_recherche", ""))
        ordered = bool(ISO.match(searched) and ISO.match(stichtag) and ISO.match(researched))
        add(
            "suchfenster",
            ordered and stichtag <= searched <= researched,
            f"{stichtag} .. {searched} .. {researched}",
        )
        berechnung = str(meta.get("berechnung", ""))
        add("berechnung", berechnung in {"ja", "nein"}, berechnung)
        basics = meta.get("rechtsgrundlagen")
        add(
            "rechtsgrundlagen",
            isinstance(basics, list) and any(str(item).strip() for item in basics),
            "",
        )
    else:
        add("stand_recherche", bool(ISO.match(str(meta.get("stand_recherche", "")))), "")

    names = h2(body)
    if overview:
        expected = ["Kurzüberblick", "Gegenstände", "Quellen"]
        add("ueberschriften", names == expected, " | ".join(names))
    else:
        berechnung = str(meta.get("berechnung"))
        expected = ["Kurzüberblick", "Rechtslage zum Stichtag", "Änderungen ab Stichtag"]
        if berechnung == "ja":
            expected += ["Werte im Zeitverlauf", "Beispielrechnung"]
        expected.append("Quellen")
        actual = []
        for name in names:
            if name.startswith("Rechtslage zum Stichtag"):
                actual.append("Rechtslage zum Stichtag")
            else:
                actual.append(name)
        add("ueberschriften", actual == expected, " | ".join(names))
        match = next((SECTION.match("## " + name) for name in names if name.startswith("Rechtslage")), None)
        if match and ISO.match(stichtag):
            year, month, day = stichtag.split("-")
            add(
                "stichtag-ueberschrift",
                (match.group(3), match.group(2), match.group(1)) == (year, month, day),
                match.group(0),
            )
        else:
            add("stichtag-ueberschrift", False, "Überschrift fehlt")

    banned = []
    if "Offene Punkte" in text:
        banned.append("Offene Punkte")
    if re.search(r"ungeprüft", text):
        banned.append("ungeprüft")
    if "<!--" in text:
        banned.append("HTML-Kommentar")
    add("keine-luecke", not banned, ", ".join(banned))

    before, _, after = body.partition("\n## Quellen")
    hits = [line.strip() for line in before.splitlines() if PARA.search(line)]
    add("normstelle", not hits, hits[0][:80] if hits else "")

    gaps = blank_lines_before_tables(body)
    add("tabellen-leerzeile", not gaps, gaps[0] if gaps else "")

    sections = dict(split_h2(body))
    quellen = sections.get("Quellen", "")
    ids = source_ids(quellen)
    add("quellen-eindeutig", len(ids) == len(set(ids)), ", ".join(ids))
    cited = [f"Q{number}" for number in QID.findall(body)]
    missing_rows = sorted(set(cited) - set(ids))
    unused = sorted(set(ids) - set(cited))
    add(
        "quellen-ids",
        not missing_rows and not unused,
        "ohne Zeile: " + ", ".join(missing_rows) + " ungenutzt: " + ", ".join(unused),
    )

    if not overview:
        chronicle = ""
        for name, content in split_h2(body):
            if name == "Änderungen ab Stichtag":
                chronicle = content
                break
        blocks = re.split(r"(?m)^(?=### )", chronicle)
        for block in blocks:
            block = block.strip("\n")
            if not block.startswith("### "):
                continue
            first = block.splitlines()[0]
            title_ok = bool(CHRON.match(first))
            gilt = []
            for line in block.splitlines():
                text = line.strip()
                if text.startswith("- "):
                    text = text[2:].strip()
                if text.startswith("Gilt bis:"):
                    gilt.append(text)
            gilt_ok = len(gilt) == 1 and bool(GILT.match(gilt[0]))
            cited_here = QID.findall(block)
            rows = [row for row in table_rows(block)]
            table_ok = True
            table_detail = ""
            if rows:
                header = rows[0]
                table_ok = header[:4] == ["Wert", "Vorher", "Nachher", "Quelle"] and len(header) == 4
                if not table_ok:
                    table_detail = " | ".join(header)
                else:
                    for row in rows[1:]:
                        if len(row) != 4 or not ONE_Q.match(row[3]):
                            table_ok = False
                            table_detail = " | ".join(row)
                            break
                        for cell in row[1:3]:
                            if BARE_NUMBER.match(cell):
                                table_ok = False
                                table_detail = "Einheit fehlt: " + cell
                                break
            add(
                "chronik:" + first[4:14],
                title_ok and gilt_ok and bool(cited_here) and table_ok,
                " ".join(
                    part
                    for part, flag in (
                        ("Strich", not title_ok),
                        ("Gilt-bis", not gilt_ok),
                        ("Quellen-ID", not cited_here),
                        (table_detail or "Tabelle", not table_ok),
                    )
                    if flag
                ),
            )
        if str(meta.get("berechnung")) == "ja":
            series = ""
            for name, content in split_h2(body):
                if name == "Werte im Zeitverlauf":
                    series = content
            series_rows = table_rows(series)
            header_ok = bool(series_rows) and series_rows[0][:5] == [
                "Parameter",
                "Ab",
                "Wert",
                "Bedingung",
                "Quelle",
            ]
            add("werte-im-zeitverlauf", header_ok, "")
            if header_ok:
                snapshot = column_amounts(
                    next((content for name, content in split_h2(body) if name.startswith("Rechtslage")), ""),
                    "Wert",
                )
                later = column_amounts(chronicle, "Nachher")
                series_at = []
                series_after = []
                for row in series_rows[1:]:
                    if len(row) < 3 or not is_amount(row[2]):
                        continue
                    if row[1] == stichtag:
                        series_at.append(norm_value(row[2]))
                    else:
                        series_after.append(norm_value(row[2]))
                missing_at = sorted({item for item in series_at if item not in snapshot})
                missing_later = sorted({item for item in series_after if item not in later})
                missing_snapshot = sorted({item for item in snapshot if item not in series_at})
                missing_change = sorted({item for item in later if item not in series_at + series_after})
                problems = []
                if missing_at:
                    problems.append("Zeitverlauf ohne Rechtslage: " + ", ".join(missing_at))
                if missing_later:
                    problems.append("Zeitverlauf ohne Chronik: " + ", ".join(missing_later))
                if missing_snapshot:
                    problems.append("Rechtslage fehlt im Zeitverlauf: " + ", ".join(missing_snapshot))
                if missing_change:
                    problems.append("Chronik fehlt im Zeitverlauf: " + ", ".join(missing_change))
                add("werte-abgleich", not problems, "; ".join(problems))

    if overview:
        subjects = ""
        for name, content in split_h2(body):
            if name == "Gegenstände":
                subjects = content
        data = table_rows(subjects)[1:]
        unlink = [row[0] for row in data if not any("](" in cell and ".md" in cell for cell in row)]
        add("uebersicht-dateien", not unlink, ", ".join(unlink))
        missing_targets = []
        for row in data:
            for cell in row:
                for match in re.finditer(r"\]\(([^)]+)\)", cell):
                    href = match.group(1).strip()
                    if href.startswith(("http://", "https://", "mailto:")):
                        continue
                    if not (path.parent / href).resolve().is_file():
                        missing_targets.append(href)
        add("uebersicht-zieldatei", not missing_targets, ", ".join(missing_targets))

    return checks


def amounts(path: Path) -> list[tuple[str, str, str, str]]:
    try:
        text = path.read_text(encoding="utf-8")
        _, body = parse_front_matter(text)
    except (OSError, ValueError):
        return []
    found = []
    for name, content in split_h2(body):
        if name.startswith("Rechtslage") or name == "Werte im Zeitverlauf":
            rows = table_rows(content)
            if not rows:
                continue
            header = rows[0]
            if "Wert" not in header:
                continue
            value_at = header.index("Wert")
            parameter_at = header.index("Parameter") if "Parameter" in header else 0
            for row in rows[1:]:
                if len(row) <= max(value_at, parameter_at):
                    continue
                found.append((path.name, name, row[parameter_at], row[value_at]))
    return found


def stichtage(paths: list[Path]) -> tuple[bool, str]:
    seen = []
    for path in paths:
        try:
            meta, _ = parse_front_matter(path.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue
        if "stichtag" in meta:
            seen.append((path.name, str(meta["stichtag"])))
    values = {value for _, value in seen}
    return len(values) <= 1, ", ".join(f"{name}={value}" for name, value in seen)


def zusammenspiel(paths: list[Path]) -> list[str]:
    subjects = [path for path in paths if path.name != "uebersicht.md"]
    if len(subjects) < 2:
        return []
    problems = []
    for path in subjects:
        try:
            lines = path.read_text(encoding="utf-8").splitlines()
        except OSError:
            continue
        capture = False
        found = False
        buf: list[str] = []
        for line in lines:
            if line.startswith("### Zusammenspiel"):
                found = True
                capture = True
                buf = []
                continue
            if capture and line.startswith("#"):
                capture = False
            if capture:
                buf.append(line)
        if found and not re.search(r"\]\([^)]+\.md\)", "\n".join(buf)):
            problems.append(path.name)
    return problems


def emit(results: list[tuple[str, str, str, str]], markdown: bool) -> None:
    if markdown:
        print("| Datei | Prüfung | Ergebnis | Detail |")
        print("|---|---|---|---|")
        for file_name, check, result, detail in results:
            detail = detail.replace("|", "/")
            print(f"| {file_name} | {check} | {result} | {detail} |")
        return
    for file_name, check, result, detail in results:
        print(f"{file_name}\t{check}\t{result}\t{detail}")


def run(paths: list[Path], markdown: bool) -> int:
    results: list[tuple[str, str, str, str]] = []
    for path in paths:
        for check, result, detail in check_file(path):
            results.append((path.name, check, result, detail))
    if len(paths) > 1:
        ok, detail = stichtage(paths)
        results.append(("*", "stichtag-gleich", "ok" if ok else "fail", detail))
        linked = zusammenspiel(paths)
        results.append(
            ("*", "zusammenspiel-link", "ok" if not linked else "fail", ", ".join(linked))
        )
    emit(results, markdown)
    if markdown:
        print()
        print("| Datei | Abschnitt | Parameter | Wert |")
        print("|---|---|---|---|")
        for file_name, section, parameter, value in (
            item for path in paths for item in amounts(path)
        ):
            print(f"| {file_name} | {section} | {parameter} | {value} |")
    failed = any(result == "fail" for _, _, result, _ in results)
    return 1 if failed else 0


def self_test() -> int:
    good = """---
titel: Beispiel
bereich: eval
gegenstand: beispiel
rechtsraum: DE
stichtag: 2020-01-01
stand_recherche: 2026-10-29
rechtsstand: 2019-01-01
berechnung: nein
rechtsgrundlagen:
  - Beispielgesetz § 1
aenderungen_geprueft_bis: 2026-10-29
---

# Beispiel

> Zusammenfassung amtlicher Quellen, keine Rechtsberatung. Maßgeblich ist der Wortlaut der Quellen.

## Kurzüberblick

- Personen können 10 Euro erhalten. [Q1]

## Rechtslage zum Stichtag 01.01.2020

### Inhalt

| Parameter | Wert | Bedingung | Quelle |
|---|---|---|---|
| Betrag | 10 Euro | je Monat | [Q1] |

## Änderungen ab Stichtag

In den geöffneten Quellen tritt nach diesem Datum keine Änderung in Kraft. [Q1]

## Quellen

| ID | Titel | Herausgeber | Fundstelle / URL | Fassung / Stand | Abgerufen |
|---|---|---|---|---|---|
| Q1 | Beispielgesetz | Stelle | § 1, https://example.invalid/g | 2019-01-01 | 2026-10-29 |
"""
    bad_para = good.replace("10 Euro erhalten", "10 Euro gemäß § 1 erhalten")
    bad_dash = good.replace(
        "In den geöffneten Quellen tritt nach diesem Datum keine Änderung in Kraft. [Q1]",
        "### 2021-04-01 - Falsch\n\n- Text [Q1]\nGilt bis: unbefristet",
    )
    with tempfile.TemporaryDirectory() as folder:
        root = Path(folder)
        (root / "good.md").write_text(good, encoding="utf-8")
        (root / "bad.md").write_text(bad_para, encoding="utf-8")
        (root / "dash.md").write_text(bad_dash, encoding="utf-8")
        good_rows = check_file(root / "good.md")
        bad_rows = check_file(root / "bad.md")
        dash_rows = check_file(root / "dash.md")
    calc = """---
titel: Beispiel
bereich: eval
gegenstand: beispiel
rechtsraum: DE
stichtag: 2020-01-01
stand_recherche: 2026-10-29
rechtsstand: 2021-04-01
berechnung: ja
rechtsgrundlagen:
  - Beispielgesetz § 1
aenderungen_geprueft_bis: 2026-10-29
---

# Beispiel

> Zusammenfassung amtlicher Quellen, keine Rechtsberatung. Maßgeblich ist der Wortlaut der Quellen.

## Kurzüberblick

- Der Betrag ist 10 Euro. [Q1]

## Rechtslage zum Stichtag 01.01.2020

### Höhe

| Parameter | Wert | Bedingung | Quelle |
|---|---|---|---|
| Betrag | 10 Euro | je Monat | [Q1] |

## Änderungen ab Stichtag

### 2021-04-01 – Betrag

- Der Betrag wird 12 Euro. [Q1]

Gilt bis: unbefristet

| Wert | Vorher | Nachher | Quelle |
|---|---|---|---|
| Betrag | 10 Euro | 12 Euro | [Q1] |

## Werte im Zeitverlauf

| Parameter | Ab | Wert | Bedingung | Quelle |
|---|---|---|---|---|
| Betrag | 2020-01-01 | 10 Euro | je Monat | [Q1] |
| Betrag | 2021-04-01 | 12 Euro | je Monat | [Q1] |

## Beispielrechnung

- Ergebnis 10 Euro. [Q1]

## Quellen

| ID | Titel | Herausgeber | Fundstelle / URL | Fassung / Stand | Abgerufen |
|---|---|---|---|---|---|
| Q1 | Beispielgesetz | Stelle | § 1, https://example.invalid/g | 2019-01-01 | 2026-10-29 |
"""
    calc_bad = calc.replace("| Betrag | 2020-01-01 | 10 Euro |", "| Betrag | 2020-01-01 | 99 Euro |")
    overview = """---
titel: Bereich
bereich: eval
rechtsraum: DE
stichtag: 2020-01-01
stand_recherche: 2026-10-29
---

# Bereich

> Zusammenfassung amtlicher Quellen, keine Rechtsberatung. Maßgeblich ist der Wortlaut der Quellen.

## Kurzüberblick

- Ein Gegenstand. [Q1]

## Gegenstände

| Gegenstand | Worum es geht | Verhältnis zu den anderen | Datei |
|---|---|---|---|
| Beispiel | Betrag | allein | [Beispiel](good.md) |

## Quellen

| ID | Titel | Herausgeber | Fundstelle / URL | Fassung / Stand | Abgerufen |
|---|---|---|---|---|---|
| Q1 | Beispielgesetz | Stelle | § 1, https://example.invalid/g | 2019-01-01 | 2026-10-29 |
"""
    overview_bad = overview.replace("(good.md)", "(missing.md)")
    with tempfile.TemporaryDirectory() as folder:
        root = Path(folder)
        (root / "calc.md").write_text(calc, encoding="utf-8")
        (root / "calc-bad.md").write_text(calc_bad, encoding="utf-8")
        (root / "good.md").write_text(good, encoding="utf-8")
        (root / "uebersicht.md").write_text(overview, encoding="utf-8")
        missing = root / "missing"
        missing.mkdir()
        (missing / "uebersicht.md").write_text(overview_bad, encoding="utf-8")
        calc_rows = check_file(root / "calc.md")
        calc_bad_rows = check_file(root / "calc-bad.md")
        overview_rows = check_file(root / "uebersicht.md")
        overview_bad_rows = check_file(missing / "uebersicht.md")
    good_fail = [name for name, result, _ in good_rows if result == "fail"]
    calc_fail = [name for name, result, _ in calc_rows if result == "fail"]
    overview_fail = [name for name, result, _ in overview_rows if result == "fail"]
    para_ok = any(name == "normstelle" and result == "fail" for name, result, _ in bad_rows)
    dash_ok = any(name.startswith("chronik:") and result == "fail" for name, result, _ in dash_rows)
    mismatch_ok = any(name == "werte-abgleich" and result == "fail" for name, result, _ in calc_bad_rows)
    link_ok = any(name == "uebersicht-zieldatei" and result == "fail" for name, result, _ in overview_bad_rows)
    if good_fail or calc_fail or overview_fail or not para_ok or not dash_ok or not mismatch_ok or not link_ok:
        print(
            "self-test failed",
            good_fail,
            calc_fail,
            overview_fail,
            para_ok,
            dash_ok,
            mismatch_ok,
            link_ok,
            calc_bad_rows,
            overview_bad_rows,
        )
        return 1
    print("self-test ok")
    return 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Prüft f-legal-Dateien mechanisch.")
    parser.add_argument("files", nargs="*", type=Path)
    parser.add_argument("--markdown", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(argv)
    if args.self_test:
        return self_test()
    if not args.files:
        parser.error("mindestens eine Datei")
    return run(args.files, args.markdown)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
