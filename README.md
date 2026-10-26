# acf

Meine Sammlung agentischer Coding-Skills (OpenCode / Claude-kompatibel).

## Skills

| Skill | Zweck |
|-------|-------|
| `f-requirements` | Freitext/Tickets → Requirement-Dokumente mit prüfbaren Acceptance Criteria |
| `f-tasks` | Requirements/Review-Findings → agentengerechte Tasks mit Abhängigkeiten |
| `f-testing` | Checks → Testplan oder Coverage-Report |
| `f-code-review` | Diff gegen ACs prüfen (Security, Performance, Side Effects) + Fix-Prompt |
| `f-debug` | Strukturierte Fehlersuche (Repro → Root Cause → Fix-Vorschlag) |
| `f-docs` | AGENTS.md, README, Architektur, Conventions aus dem Repo erzeugen |
| `f-legal` | Regulatorische Vorgaben (DE/EU) → `docs/legal/` |
| `f-workflow` | Menü + Prompt-Templates für den Ablauf (führt selbst nichts aus) |

Der Kernzyklus: Requirements → Tasks → Testing → Implementation → Review. `f-debug` ist der Seitenzweig, wenn etwas fehlschlägt.

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
`reviews/`, `debug/`, `legal/`, `conventions/`, `decisions/`).

## Dokumentation

- [AGENTS.md](AGENTS.md) — Hinweise für AI-Agenten
- [docs/architecture.md](docs/architecture.md) — Aufbau und Datenfluss
- [docs/decisions/index.md](docs/decisions/index.md) — Inhaltsverzeichnis der Entscheidungen
- [docs/conventions/index.md](docs/conventions/index.md) — Inhaltsverzeichnis der Konventionen für die Skill-Dateien
