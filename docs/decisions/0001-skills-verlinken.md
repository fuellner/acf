# Skills werden verlinkt, nicht kopiert

**Status:** accepted  
**Datum:** 2026-10-26

## Entscheidung

Die Skills in `skills/f-*` werden per Symlink in das Skill-Verzeichnis des Agenten eingebunden. Es werden keine Kopien angelegt.

## Kontext

Das Repository ist die einzige Quelle für die Skills. Kopien würden nach Änderungen im Repo auseinanderdriften und zu uneindeutigem Verhalten führen.

## Konsequenzen

- Installation erfolgt mit `ln -s ~/dev/acf/skills/f-* ~/.config/opencode/skills/`.
- Änderungen im Repo wirken sofort in der Installation; es gibt keinen Synchronisationsschritt.
- Ein Umbenennen oder Verschieben eines Skill-Verzeichnisses bricht bestehende Symlinks und muss bewusst erfolgen.
