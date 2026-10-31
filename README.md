# agentic coding flow

Meine Sammlung agentischer Coding-Skills (OpenCode / Claude-kompatibel).

## Skills

| Skill | Zweck |
|-------|-------|
| `f-requirements` | Freitext/Tickets → Requirement-Dokumente mit prüfbaren Acceptance Criteria |
| `f-tasks` | Requirements/Review-Findings → agentengerechte Tasks mit Abhängigkeiten |
| `f-testing` | Checks → Testplan oder Coverage-Report |
| `f-implement` | Task umsetzen (`tdd` oder `direct`) auf einem Dev-Branch, ohne Commit und ohne Push |
| `f-code-review` | Diff gegen ACs prüfen (Security, Performance, Side Effects) + Fix-Prompt |
| `f-debug` | Strukturierte Fehlersuche (Repro → Root Cause → Fix-Vorschlag) |
| `f-docs` | README, Architektur, Conventions aus dem Repo; `AGENTS.md` nur wenn keine existiert und zugestimmt wird |
| `f-legal` | Deutsches Recht zum Stichtag, nur amtliche Quellen → `docs/legal/` |
| `f-feature-summary` | Implementierte Fachlogik → übersichtliche Feature-Dokumente (`docs/features/`) |
| `f-refactor` | Eigener Ablauf: verhaltensgleiche PHP-Migration (vorrangig) oder Struktur-Refactor, Phasenmenü, Status unter `docs/refactor/` |
| `f-workflow` | Menü für den Feature-Ablauf; übergibt Migration und Refactor an `f-refactor` |

Der Kernzyklus: Requirements → Tasks → Testing → Implement → Review. `f-debug` ist der Seitenzweig, wenn etwas fehlschlägt. `f-refactor` ist ein zweiter Ablauf daneben, kein Schritt darin. Es nutzt `f-tasks`, `f-testing`, `f-implement`, `f-code-review`, `f-debug` und `f-docs`. Die Codeänderung eines Schritts übergibt die Step-Phase an `f-implement`. Feature- und Bugfix-Arbeit geht zurück an `f-workflow`.

## Installation

Das Repo ist die einzige Quelle. Die Skills werden **verlinkt**, nicht kopiert — sonst driften
Repo und Installation auseinander.

```bash
mkdir -p ~/.config/opencode/skills
ln -s ~/dev/acf/skills/f-* ~/.config/opencode/skills/
```

Prüfen:

```bash
ls -l ~/.config/opencode/skills     # jeder Eintrag zeigt in dieses Repo
```

Für projektlokale Nutzung alternativ nach `.opencode/skills/` bzw. `.agents/skills/` verlinken.

## Struktur

```text
skills/<name>/
  SKILL.md        # Frontmatter (name, description) + Ablauf
  templates/      # Vorlagen für die Artefakte im Zielrepo
  references/     # Detailwissen, nur bei Bedarf geladen
  CHANGELOG.md
```

Erzeugte Dokumente landen im Zielrepo unter `docs/` (`requirements/`, `tasks/`, `tests/`,
`implement/`, `reviews/`, `debug/`, `legal/`, `features/`, `refactor/`, `conventions/`, `decisions/`).
`f-debug` schreibt immer nach `docs/debug/`; ein Review, das die Analyse ausgelöst hat, verlinkt den Bericht.

## Prüfung

Eine allgemeine Test-, Lint- oder Typecheck-Kette gibt es nicht. Ausnahme:

```bash
python3 skills/f-legal/scripts/check.py --self-test
```

## Vorlagen im Root

`AGENTS.md`, `MEMORY.md`, `LEARNINGS.md` und `ERRORS.md` sind allgemeine Vorlagen zum Kopieren in ein Zielprojekt. `AGENTS.md` ist eine normale Datei mit demselben Text wie `skills/f-docs/templates/agents.md.tmpl`. Die drei Gedächtnis-Dateien bleiben leer, bis die Arbeit Einträge erzeugt. `f-docs` legt sie nicht an.

Regeln, die nur hier gelten (Remote, Umbenennen eines Skills, Besitz von `docs/legal/`, `docs/refactor/` und `docs/implement/`), stehen in [docs/conventions/markdown.md](docs/conventions/markdown.md).

## Dokumentation

- [AGENTS.md](AGENTS.md) — allgemeine Agenten-Vorlage
- [docs/architecture.md](docs/architecture.md) — Aufbau und Datenfluss
- [docs/decisions/index.md](docs/decisions/index.md) — Inhaltsverzeichnis der Entscheidungen
- [docs/conventions/index.md](docs/conventions/index.md) — Inhaltsverzeichnis der Konventionen für die Skill-Dateien
- [f-refactor Ablauf](skills/f-refactor/references/workflow.md) — Phasen, Artefakte, Status, Übergaben
- [f-refactor Werkzeuge](skills/f-refactor/references/toolchain.md) — isolierte PHP-Werkzeuge, nicht im Anwendungsprojekt
