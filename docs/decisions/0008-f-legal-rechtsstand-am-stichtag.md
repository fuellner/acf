# f-legal recherchiert den Rechtsstand am Stichtag

**Status:** accepted  
**Datum:** 2026-10-28

## Entscheidung

`f-legal` hält den Rechtsstand eines Gegenstands des deutschen Rechts zu einem Stichtag fest. Der Gegenstand ist ein Gesetz, eine Verordnung, eine Norm oder eine Leistungsart. Der Stichtag ist ein Datum oder ein Jahr; ein Jahr ist der 1. Januar. Fehlt er, wird gefragt, nicht das heutige Datum eingesetzt.

- Quellen sind amtliche Texte deutscher staatlicher Stellen, Bund und Länder. EU-Recht, Kommentare und Anwendungscode sind keine Quelle. Entscheidungen von Bundesgerichten aus amtlichen Sammlungen sind eine nachgeordnete Quelle für die Auslegung, nie für Beträge, Schwellen, Dauern oder Inkrafttreten. Ergänzt am 2026-10-29.
- Zuerst wird der amtliche Gesetzestext gelesen. Anker der Fassung am Stichtag ist die letzte amtliche Neubekanntmachung davor, danach nur die Änderungen der betroffenen Vorschrift. Die Chronik kommt aus den Änderungsgesetzen und dem Inkrafttreten des jeweiligen Artikels. Die heutige Lesefassung wird nicht zum früheren Stand zurückgerechnet. Eine datierte Veröffentlichung eines Ministeriums oder eine amtliche Bekanntmachung darf einen Betrag tragen, wenn nicht die geöffnete Norm eine andere Zahl setzt.
- Angehalten wird nur, wenn der Wortlaut dieser Vorschrift am Stichtag oder eine Änderung dieser Vorschrift nicht geöffnet werden kann. Eine Fußnote, die nur eine andere Vorschrift trifft, stoppt nicht. Sie wird im Bericht genannt, nicht im Dokument. Ein Gegenstand, dessen Text fehlt, kommt nicht in die Übersicht.
- Je Gegenstand entsteht eine Datei `docs/legal/<bereich>/<gegenstand>.md`. Im Sammelmodus schreibt die führende Recherche zuerst die Übersicht des Bereichs, danach jeden Gegenstand mit derselben Vorlage und denselben Regeln, und gleicht am Ende Struktur, Begriffe, Werte, Stichtag und Widersprüche ab.
- Der Kopf, die Überschriften der zweiten Ebene und die Quellen-IDs sind fest. `rechtsgrundlagen` und `aenderungen_geprueft_bis` stehen im Kopf. Normstellen stehen dort und in der Quellenliste, nicht im Lauftext und nicht in den Wertetabellen. Werte stehen in Tabellen, mit Einheit. Jeder Chronikeintrag nennt sein Änderungsgesetz und `Gilt bis`. Bei Geld oder Rechnung gibt es die Beispielrechnung und die Tabelle Werte im Zeitverlauf. Einen Abschnitt „Offene Punkte“ gibt es nicht. Das Dokument ist keine Rechtsberatung.
- Die Index-Spalten unter `docs/legal/` sind `Bereich | Dokument | Stichtag | Rechtsstand | Zuletzt geprüft`. Die gemeinsame Referenz benennt sie.

## Kontext

Die bisherige Fassung zog aus Quellen developer-relevante Regeln, verlangte in jedem Gültigkeitsabschnitt eine Beispielrechnung und verwendete einen großen Teil der Anweisung auf den Index. Ein Lauf über die Leistungsarten der Pflegeversicherung war für Menschen und für andere Agenten nicht lesbar. Werte konnten aus dem Gedächtnis stammen, weil kein Schritt das Öffnen der amtlichen Fassung verlangte. Ein Probelauf mit einer Entwurfvorlage baute den Stand am Stichtag aus dem heutigen Text zurück und ließ Änderungen aus, die nur in den Änderungsgesetzen stehen.

## Konsequenzen

- `f-workflow`, die Architektur und die README beschreiben `f-legal` als Recherche des deutschen Rechts zum Stichtag. Die Sprachregel und die Zuständigkeit für `docs/legal/` stehen in `docs/conventions/markdown.md`. Die allgemeine `AGENTS.md` wiederholt sie nicht. Stand 2026-10-31; Begründung in [0009-agents-md-optional-eine-quelle.md](0009-agents-md-optional-eine-quelle.md).
- 0003 gilt weiter. Die Spalten stehen in der Index-Vorlage und sind in `skills/f-docs/references/directory-index.md` benannt. Eine alte Tabelle mit `Rechtsgrundlage` und `Gültig ab` wird aus den Dateien neu aufgebaut.
- Der Skill nennt kein Werkzeug eines bestimmten Agenten und trägt keine Git-Identität ein. Er schreibt keine Commits.
- Die Prüfungen liegen unter `skills/f-legal/evals/`. Fixtures dort sind keine Rechtsquellen. `scripts/check.py` prüft Kopf, Überschriften, Normstellen außerhalb der Quellenliste und die Quellen-IDs, bevor der Bericht die Beträge vergleicht.
