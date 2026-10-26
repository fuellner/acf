# AGENTS-Template heißt `agents.md.tmpl`

**Status:** accepted  
**Datum:** 2026-10-26

## Entscheidung

Die Vorlage für `AGENTS.md` liegt als `templates/agents.md.tmpl` vor und trägt einen `TEMPLATE (f-docs)`-Kopf, der beim Kopieren entfernt wird.

## Kontext

Eine Datei mit dem Namen `AGENTS.md` wird von Agent-Harnesses automatisch als aktive Anweisung geladen. Eine so benannte Vorlage im Skill-Verzeichnis würde dadurch als Projektregel wirken.

## Konsequenzen

- Neue Vorlagen, die ein Harness automatisch laden könnte, dürfen nicht den aktiven Dateinamen tragen.
- Beim Erzeugen von `AGENTS.md` wird der Template-Kommentar entfernt und die Platzhalter werden gefüllt.
