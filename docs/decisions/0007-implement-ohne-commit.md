# Implementierung ohne Commit, ein Worktree pro parallelem Task

**Status:** accepted  
**Datum:** 2026-10-28

## Entscheidung

`f-implement` ist der Implementierungsschritt im Feature-Ablauf, zwischen dem Testplan und dem Review.

- Der Agent legt nur den Branch `dev/<KEY>-<kurz-titel>` an. Er committet nicht, pusht nicht und setzt `user.name` und `user.email` nicht. Der Mensch prüft den Diff und committet selbst.
- Der Schlüssel im Branch ist das optionale Ticket-Feld, wenn es genau einen Schlüssel trägt. Einen Schlüssel, der nur im Titel oder Text steht, zeigt der Skill und lässt ihn einmal bestätigen. Sonst gilt die Task-ID. Ein Schlüssel wird nicht erfunden und kein Tracker aufgerufen.
- Mehrere Tasks laufen nur, wenn sie unabhängig sind und der User die Menge freigibt. Jeder dieser Tasks bekommt einen eigenen `git worktree` und einen eigenen Branch, alle vom selben Basis-Commit. Task-Datei und Testplan müssen in diesem Commit liegen, weil ein Worktree nur committete Dateien enthält. Der Skill committet nicht. Kann die Laufzeit die Worktrees nicht an eigene Agenten geben, laufen sie nacheinander. Der Skill entfernt keine Worktrees.
- Ein einzelner Task bleibt im aktuellen Worktree.
- Ein Refactor- oder Migrationsschritt wird über die Step-Phase von `f-refactor` ausgeführt. Diese Phase übergibt die Codeänderung an `f-implement`. `f-implement` nimmt keine solche Aufgabe an, die den Plan umgeht.

## Kontext

Der Feature-Ablauf hatte an dieser Stelle keinen Skill. 0004 hielt deshalb fest, dass Implementation kein eigener Skill ist. Der Ablauf soll geschlossen sein, ohne dass der Agent im Namen des Users committet. Dieselbe Person nutzt unterschiedliche Git-Identitäten für einen öffentlichen und einen internen Remote; der Skill darf keine Identität fest eintragen.

Git kann denselben Branch nicht in zwei Worktrees auschecken. Parallele Tasks brauchen deshalb je einen eigenen Branch.

## Konsequenzen

- 0004, letzte Konsequenz, verweist auf diese Entscheidung. 0005 bleibt gültig; die Step-Phase übergibt zusätzlich an `f-implement`.
- Das Protokoll liegt unter `docs/implement/` im Zielrepo. `docs/tasks/` bleibt die Task-Liste, weil deren Index nur Tasks führt.
- `f-workflow` führt `f-implement` an der bisherigen Stelle von Implementation. Die Reihenfolge Requirements, Tasks, Testing, Implement, Review bleibt.
- Vor dem Branch liest der Skill die wirksame Autor- und Committer-Identität. Fehlt sie, oder wirkt sie für den Remote unpassend, fragt er einmal. Auf einem öffentlichen Forge fragt er auch, wenn die E-Mail weder ein öffentliches Postfach noch die Noreply-Domain dieses Forge ist. Er schreibt die Konfiguration nicht.
