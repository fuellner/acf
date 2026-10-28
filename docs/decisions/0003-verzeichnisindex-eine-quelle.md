# Verzeichnisindex hat eine Quelle

**Status:** accepted  
**Datum:** 2026-10-26

## Entscheidung

Die Regeln für `index.md` unter `docs/` stehen einmal in `skills/f-docs/references/directory-index.md`. Jeder andere `f-*`-Skill enthält `references/directory-index.md` als relativen Symlink auf diese Quelle. `SKILL.md` enthält nur einen kurzen Verweis und die skill-eigenen Einschränkungen.

Fehlt ein Schema, heißen die beiden Spalten `Document | Description`. In deutschsprachigen, menschenlesbaren Indizes heißen dieselben Spalten `Dokument | Beschreibung`. Requirements, Tasks, Tests, Features und die f-legal-Vorlage behalten ihr jeweiliges Schema; es ist in derselben Referenz benannt. Das Tests-Schema ist `Source | Mode | Revision | File`.

## Kontext

Dieselbe Index-Anweisung stand in allen acht Skills, im Implementation-Prompt von `f-workflow` und in der Task-Vorlage. Die Kopien drifteten, sichtbar an den Fallback-Spalten `Document | Description` und `Dokument | Beschreibung`.

Skills werden einzeln per Symlink installiert (`~/.config/opencode/skills/f-*` → `skills/f-*`). Ein Skill kann Dateien außerhalb seines eigenen Verzeichnisses nicht zuverlässig laden, wenn der Pfad nur neben dem Installations-Symlink aufgelöst wird. Ein Symlink innerhalb von `references/` zeigt auf `../../f-docs/references/directory-index.md` und wird relativ zum echten Pfad des Skills im Repository aufgelöst. Das funktioniert, solange die Skills Geschwister unter `skills/` sind, auch wenn im Agenten nur dieser eine Skill verlinkt ist.

Ein Verweis auf `docs/conventions/` aus dem Installationsverzeichnis (`~/.config/opencode/skills/f-*/../../docs`) trifft das Repository nicht. Eine weitere Textkopie in jedem Skill würde wieder auseinanderlaufen.

Texte, die ins Zielrepository kopiert werden (Task-Vorlage, Implementation-Prompt), nennen den Skill `f-docs` und die Datei `references/directory-index.md`. Dieselbe Datei liegt über den Symlink in jedem `f-*`-Skill, damit ein installierter Skill sie aus dem eigenen Verzeichnis laden kann. Ein skill-relativer Link in der Kopie im Zielrepository würde nicht auflösen.

## Konsequenzen

- Index-Regeln werden nur in `skills/f-docs/references/directory-index.md` geändert.
- Weitere Skills bekommen denselben relativen Symlink, keinen eigenen Regeltext.
- `f-legal` bleibt deutsch und verweist auf die englische Referenz. Die rechtlichen Spalten stehen in seiner Index-Vorlage und sind in der Referenz benannt.
- `docs/tests/` führt `Source | Mode | Revision | File`, damit ein Review die Datei über die Source-ID findet. Leitet ein Task von einem Requirement ab, ist diese ID die REQ-ID.
- Wer ein Skill-Verzeichnis ohne diesen Symlink und ohne das Geschwisterverzeichnis `f-docs` kopiert, verliert die Index-Regel. Die Installation bleibt das Verlinken der `skills/f-*`-Verzeichnisse.
