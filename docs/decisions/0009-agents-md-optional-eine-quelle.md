# AGENTS.md ist optional

**Status:** accepted  
**Datum:** 2026-10-31

## Entscheidung

`f-docs` behandelt `AGENTS.md` als optionale Datei.

- Existiert sie im Zielrepository, fragt der Skill nicht und schreibt sie nicht um.
- Fehlt sie, fragt er einmal. Nur ein ausdrückliches Ja erzeugt die Datei, als bytegleiche Kopie von `skills/f-docs/templates/agents.md.tmpl`. Ein Nein oder eine offene Frage lässt sie fehlen.
- Die Root-`AGENTS.md` ist die Vorlage, von der der Owner kopiert. `skills/f-docs/templates/agents.md.tmpl` wird bei Änderungen von Hand mitgezogen. Dafür gibt es kein Skript und keine Prüfung.
- Sprachregeln stehen in den Konventionsvorlagen für PHP, Python, TypeScript und SQL. `AGENTS.md` verweist auf `docs/conventions/`.
- `MEMORY.md`, `LEARNINGS.md` und `ERRORS.md` im Root sind leere Vorlagen zum Kopieren. Der Skill legt sie nicht an und füllt sie nicht. Einträge entstehen bei der Arbeit.

## Kontext

Die Vorlage hat `AGENTS.md` bisher immer geschrieben und allgemeine Änderungsregeln mit den Sprachdateien vermischt. Die Root-Datei dieses Repositories war zusätzlich projektspezifisch und damit als Kopiervorlage unbrauchbar. Sie ist wieder eine eigene normale Datei. Von ihr wird kopiert.

## Konsequenzen

- 0002, letzte Konsequenz, verweist auf diese Entscheidung. Der Dateiname `agents.md.tmpl` bleibt. Der `TEMPLATE (f-docs)`-Kopf und das Füllen von Platzhaltern entfallen.
- Die Sprachregel für `f-legal` und der Besitz von `docs/legal/` stehen in `docs/conventions/markdown.md`, nicht in der allgemeinen `AGENTS.md`. 0008 verweist darauf.
- Grenzen, die nur dieses Repository betreffen (Remote, Umbenennen eines Skills, Besitz von `docs/refactor/` und `docs/implement/`), stehen dort ebenfalls. Prüfbefehl und die Einordnung der Root-Vorlagen stehen in der README.
- `f-workflow` nennt `AGENTS.md` im f-docs-Prompt als optional.
