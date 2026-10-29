# f-legal recherchiert den Rechtsstand am Stichtag

**Status:** accepted  
**Datum:** 2026-10-28

## Entscheidung

`f-legal` hält den Rechtsstand eines Gegenstands des deutschen Rechts zu einem Stichtag fest. Der Gegenstand ist ein Gesetz, eine Verordnung, eine Norm oder eine Leistungsart. Der Stichtag ist ein Datum oder ein Jahr; ein Jahr ist der 1. Januar. Fehlt er, wird gefragt, nicht das heutige Datum eingesetzt.

- Quellen sind nur amtliche Texte deutscher staatlicher Stellen, Bund und Länder. EU-Recht, Kommentare, Urteile und Anwendungscode sind keine Quelle. Eine nicht erreichbare benötigte Fassung stoppt die Recherche. Es wird kein Wert aus dem Gedächtnis gesetzt.
- Zuerst wird der amtliche Gesetzestext gelesen, danach Verordnungen, amtliche Begründungen und amtliche Bekanntmachungen. Die Fassung am Stichtag und die späteren Änderungen werden über die Änderungsgesetze und ihr Inkrafttreten belegt. Die heutige Lesefassung wird nicht zum früheren Stand zurückgerechnet.
- Je Gegenstand entsteht eine Datei `docs/legal/<bereich>/<gegenstand>.md`. Im Sammelmodus schreibt die führende Recherche zuerst die Übersicht des Bereichs, danach jeden Gegenstand mit derselben Vorlage und denselben Regeln, und gleicht am Ende Struktur, Begriffe, Werte, Stichtag und Widersprüche ab.
- Der Kopf, die Überschriften der zweiten Ebene und die Quellen-IDs sind fest. Normstellen stehen nur in der Quellenliste. Werte stehen in Tabellen. Eine Beispielrechnung gibt es nur bei Geld oder Rechnung und nur aus belegten Werten. Einen Abschnitt „Offene Punkte“ gibt es nicht. Das Dokument ist keine Rechtsberatung.
- Die Index-Spalten unter `docs/legal/` sind `Bereich | Dokument | Stichtag | Rechtsstand | Zuletzt geprüft`. Die gemeinsame Referenz benennt sie.

## Kontext

Die bisherige Fassung zog aus Quellen developer-relevante Regeln, verlangte in jedem Gültigkeitsabschnitt eine Beispielrechnung und verwendete einen großen Teil der Anweisung auf den Index. Ein Lauf über die Leistungsarten der Pflegeversicherung war für Menschen und für andere Agenten nicht lesbar. Werte konnten aus dem Gedächtnis stammen, weil kein Schritt das Öffnen der amtlichen Fassung verlangte. Ein Probelauf mit einer Entwurfvorlage baute den Stand am Stichtag aus dem heutigen Text zurück und ließ Änderungen aus, die nur in den Änderungsgesetzen stehen.

## Konsequenzen

- `f-workflow`, die Architektur und die README beschreiben `f-legal` als Recherche des deutschen Rechts zum Stichtag. `AGENTS.md` bleibt: der Skill, seine Vorlagen und `docs/legal/` sind deutsch, und das Verzeichnis gehört nur diesem Skill.
- 0003 gilt weiter. Die Spalten stehen in der Index-Vorlage und sind in `skills/f-docs/references/directory-index.md` benannt. Eine alte Tabelle mit `Rechtsgrundlage` und `Gültig ab` wird aus den Dateien neu aufgebaut.
- Der Skill nennt kein Werkzeug eines bestimmten Agenten und trägt keine Git-Identität ein. Er schreibt keine Commits.
- Die Prüfungen liegen unter `skills/f-legal/evals/`. Fixtures dort sind keine Rechtsquellen.
