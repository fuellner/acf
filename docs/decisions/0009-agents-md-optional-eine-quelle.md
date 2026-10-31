# AGENTS.md ist optional und hat eine Quelle

**Status:** accepted  
**Datum:** 2026-10-31

## Entscheidung

`f-docs` behandelt `AGENTS.md` als optionale Datei.

- Existiert sie im Zielrepository, fragt der Skill nicht und schreibt sie nicht um.
- Fehlt sie, fragt er einmal. Nur ein ausdrückliches Ja erzeugt die Datei, als bytegleiche Kopie von `skills/f-docs/templates/agents.md.tmpl`. Ein Nein oder eine offene Frage lässt sie fehlen.
- Der Text steht nur in dieser Vorlage. Die Root-`AGENTS.md` dieses Repositories ist ein relativer Symlink darauf. In ein Zielprojekt wird der Dateiinhalt kopiert (`cp -L`), nicht der Symlink.
- Sprachregeln stehen in den Konventionsvorlagen für PHP, Python, TypeScript und SQL. `AGENTS.md` verweist auf `docs/conventions/`.
- `MEMORY.md`, `LEARNINGS.md` und `ERRORS.md` im Root sind leere Vorlagen zum Kopieren. Der Skill legt sie nicht an und füllt sie nicht. Einträge entstehen bei der Arbeit.

## Kontext

Die Vorlage hat `AGENTS.md` bisher immer geschrieben und allgemeine Änderungsregeln mit den Sprachdateien vermischt. Die Root-Datei dieses Repositories war zusätzlich projektspezifisch und damit als Kopiervorlage unbrauchbar. Eine zweite Textfassung würde auseinanderlaufen, wie zuvor bei den Verzeichnisindex-Regeln (0003).

## Konsequenzen

- 0002 gilt für den Dateinamen `agents.md.tmpl`. Der `TEMPLATE (f-docs)`-Kopf und das Füllen von Platzhaltern in `AGENTS.md` entfallen.
- Die Sprachregel für `f-legal` und der Besitz von `docs/legal/` stehen in `docs/conventions/markdown.md`, nicht in der allgemeinen `AGENTS.md`. 0008 verweist darauf.
- Grenzen, die nur dieses Repository betreffen (Remote, Umbenennen eines Skills, Besitz von `docs/refactor/` und `docs/implement/`), stehen dort ebenfalls. Prüfbefehl und die Einordnung der Root-Vorlagen stehen in der README.
- `f-workflow` nennt `AGENTS.md` im f-docs-Prompt als optional.
