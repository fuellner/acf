# Schreiben

Lies diese Datei, bevor du schreibst. Die Vorlage `templates/document.md` ist die Struktur. Beispiele in dieser Datei zeigen die Form. Sie sind keine Rechtswerte und werden nicht in ein Zieldokument übernommen.

## Zwei Leser

Ein Mensch soll in wenigen Stichpunkten verstehen, worum es geht, wer betroffen ist, was gilt und was sich seit dem Stichtag geändert hat. Ein Agent soll Felder, Überschriften und Quellen-IDs stabil vorfinden und Werte aus Tabellen lesen, nicht aus einem umschriebenen Satz raten.

Deshalb: einfache Sätze, vollständiger Inhalt, feste Struktur. Nichts Sachliches ohne Quelle. Nichts, was die Quelle nicht hergibt.

## Datei

Pfad: `docs/legal/<bereich>/<gegenstand>.md`

Beide Slugs: Kleinbuchstaben `a` bis `z`, Ziffern, Bindestriche. Umlaute zu `ae`, `oe`, `ue`, `ß` zu `ss`. Der Bereich ist das Rechtsgebiet, der Gegenstand die Norm oder die Leistungsart. Dieselbe Sache behält denselben Slug.

Der Kopf hat genau diese Felder:

- `titel`, `bereich`, `gegenstand` — Klartext und die beiden Slugs
- `rechtsraum` — immer `DE`
- `rechtsgrundlagen` — Liste der Normen. Die Normstelle steht hier, nicht im Lauftext
- `stichtag` — `JJJJ-MM-TT`. Ein Jahr wird zu `JJJJ-01-01`
- `stand_recherche` — das Datum, an dem die Quellen in diesem Lauf geöffnet wurden. Nicht der Stichtag, solange nicht an diesem Tag recherchiert wurde
- `rechtsstand` — das Inkrafttreten der letzten berücksichtigten Änderung. Liegt nach dem Stichtag keine Änderung, ist es das Inkrafttreten der Fassung, die am Stichtag gilt. Dieses Datum steht in einer Quelle. Es wird nicht auf den Stichtag gesetzt, nur weil der Stichtag so lautet
- `aenderungen_geprueft_bis` — der Tag, bis zu dem Änderungen dieser Vorschrift gesucht wurden. Siehe `references/recherche.md`
- `berechnung` — `ja` oder `nein`

`berechnung` ist `ja` nur, wenn die Norm Geld oder eine Rechnung regelt und ein Beispiel vollständig aus Werten dieser Quellen gebaut werden kann. Gesetzliche Beträge, ein gesetzlicher Teiler wie 30 Tage und ein gesetzlicher Anteil reichen. Einkommen, Stunden oder ein Familienstand, den die Quelle nicht nennt, werden nicht erfunden. Fehlt ein solcher Wert, ist `berechnung` `nein` und die Abschnitte Beispielrechnung und Werte im Zeitverlauf entfallen.

## Überschriften

Fest, in dieser Reihenfolge:

1. `Kurzüberblick`
2. `Rechtslage zum Stichtag TT.MM.JJJJ` — das Datum ausgeschrieben, passend zu `stichtag`
3. `Änderungen ab Stichtag`
4. `Werte im Zeitverlauf` — nur bei `berechnung: ja`
5. `Beispielrechnung` — nur bei `berechnung: ja`
6. `Quellen`

Die Überschriften der dritten Ebene unter der Rechtslage in der Vorlage sind die Vorgabe für Leistungsarten. Bei einem anderen Gegenstand die dritte Ebene so benennen, dass sie den Gegenstand trifft. Eine leere dritte Ebene weglassen. Eine dritte Ebene ohne Quelle nicht anlegen. Die zweite Ebene bleibt.

Im Sammelmodus enthält „Zusammenspiel mit anderen Leistungen“ einen relativen Link auf die Datei des benachbarten Gegenstands, zum Beispiel `[Sachhilfe](zusammentreffen.md)`.

Die Chronik-Überschriften haben die Form `JJJJ-MM-TT – Kurztitel` mit dem Gedankenstrich `–`. Das Datum ist das Inkrafttreten. Der Kurztitel sagt in Klartext, was sich ändert. Den Satz unter der Überschrift `Änderungen ab Stichtag` aus der Vorlage übernehmen, solange es Einträge gibt. Ein Eintrag beschreibt nur, was dieses Änderungsgesetz an dieser Vorschrift ändert. Die heutige Lesefassung nicht darunter nacherzählen.

Jeder Eintrag hat eine eigene Zeile `Gilt bis: JJJJ-MM-TT` oder `Gilt bis: unbefristet`. Die Quellen-ID am Stichpunkt und in der Spalte Quelle ist die des Änderungsgesetzes, das die Änderung druckt, nicht die der Lesefassung. Genau eine ID in der Spalte Quelle.

Zwei Artikel desselben Gesetzes mit verschiedenen Tagen werden zwei Einträge mit derselben Quellen-ID. Zwei Gesetze mit demselben Tag werden zwei Einträge. Das früher verkündete steht zuerst. Zwei Artikel desselben Gesetzes mit demselben Tag sind ein Eintrag mit mehreren Stichpunkten.

Gibt es nach dem Stichtag keine gelesene Änderung dieser Vorschrift, bleibt die Überschrift und ein Satz: in den geöffneten Quellen tritt nach diesem Datum keine Änderung dieser Vorschrift in Kraft. Keine erfundene Überschrift `JJJJ-MM-TT`.

## Sätze und Tabellen

Zwei bis fünf Stichpunkte im Kurzüberblick: was es ist, wen es betrifft, wofür, die wichtigsten Eckwerte. Die Eckwerte stehen hier mit ihrer Zahl. Der Kurzüberblick darf wiederholen, was die Tabelle darunter genauer ausweist. Diese Ausnahme gilt nur für ihn.

Jeder sachliche Stichpunkt ist ein Satz in Klartext und endet mit der Quellen-ID: `[Q1]`. Mehrere Quellen: `[Q1][Q2]`. Unterhalb des Kurzüberblicks dieselbe Aussage nicht unter einer zweiten Überschrift wiederholen. Eine Überleitung zu einer Tabelle braucht keine ID, wenn die Tabelle selbst eine Quelle je Zeile nennt.

Vor jeder Tabelle steht eine Leerzeile, auch nach einem Stichpunkt und nach einer Überschrift. Sonst stellt der Renderer die Tabelle nicht dar.

Keine Normstelle im Lauftext und nicht in den Zellen der Wertetabellen. Kein `§`, kein „Absatz 3 Satz 2“. Die Stelle steht in `rechtsgrundlagen` und in der Quellenliste. „Grad 2“ bleibt, das ist der Begriff der Quelle, keine Fundstelle.

Zahlen, Schwellen, Anteile, Dauern und Vorher-nachher-Paare stehen in einer Tabelle, auch in der Chronik. Die Einheit steht in der Zelle: `200 Euro`, `30 Tage`, nicht `200`. Dieselbe Zahl darf im Kurzüberblick stehen. In der Tabelle steht sie immer.

Die Chroniktabelle hat die Spalten `Wert | Vorher | Nachher | Quelle`. Nur aufnehmen, wenn sich eine solche Größe ändert. `Vorher` ist der Wert unmittelbar vor diesem Inkrafttreten, `Nachher` der neue Wert, beide aus geöffneten Texten. `Quelle` ist die ID des Änderungsgesetzes. Eine leere Tabelle nicht anlegen.

Vollständig heißt: wer betroffen ist und wer nicht, welche Bedingung gilt, was geschuldet ist, in welcher Höhe und Dauer, welche Ausnahme, welches Verfahren, welches Zusammenspiel. Eine Ausnahme, eine Stufe oder eine Frist, die in der Quelle steht, fehlt nicht. „kann“ bleibt „kann“, „muss“ und „hat zu“ bleiben eine Pflicht, „auf Wunsch“ bleibt freiwillig.

Nicht der Gesetzestext im Wortlaut. Ein Stichpunkt, eine Aussage. Eine größere Änderung bekommt mehrere Stichpunkte.

Formbeispiel, keine Rechtsaussage:

Schlecht: „Gemäß § 4 Abs. 2 S. 1 beträgt die Leistung ggf. rund 200 Euro. Offene Punkte bleiben.“

Besser: „Personen mit Grad 2, die die Hilfe selbst sicherstellen, können die Leistung für einen vollen Kalendermonat erhalten [Q1].“ Die Höhe steht in der Tabelle, Zelle `200 Euro`, Quelle `[Q1]`.

Den Hinweis aus der Vorlage stehen lassen. Keine Rechtsberatung, kein Rat zu einem Einzelfall, kein Abschnitt „Offene Punkte“, kein „ungeprüft“. Platzhalter und HTML-Kommentare aus der Vorlage nicht mitnehmen.

## Werte im Zeitverlauf

Nur bei `berechnung: ja`. Die Tabelle wird nur aus der Rechtslage zum Stichtag und aus den Chronikeinträgen gebaut. Keine zusätzliche Recherche, kein Betrag, der dort nicht steht.

| Parameter | Ab | Wert | Bedingung | Quelle |
|---|---|---|---|---|

Die erste Zeile eines Parameters trägt als `Ab` den Stichtag und den Wert, der an diesem Tag gilt. Jede spätere Zeile trägt das Inkrafttreten der Änderung und den Wert `Nachher`. Eine Befristung aus der Chronik steht in `Bedingung`, zum Beispiel `bis 2021-12-31`. `Quelle` ist dieselbe ID wie an der Stelle, der der Wert entnommen ist.

## Beispielrechnung

Nur bei `berechnung: ja`. Annahmen, Rechenweg, Ergebnis. Jede Zahl kommt aus einer Quelle und trägt ihre ID. Keine Fallzahl erfinden, die die Norm nicht nennt, auch keine Anzahl von Tagen. Ein voller Monat mit dem gesetzlichen Betrag ist bestimmt. Ein Teiler oder ein Anteil wird nur angesetzt, wenn die Norm diese Rechnung nennt und die eingesetzten Zahlen aus ihr stammen. Eine Beispielrechnung zum Stand am Stichtag benutzt die Werte dieses Stands. Eine Rechnung zu einer späteren Fassung nennt deren Inkrafttreten und benutzt deren Werte.

## Quellen

Eine Liste. Beim ersten Anlegen `Q1`, `Q2`, … in der Reihenfolge der ersten Nennung.

Beim Fortschreiben einer Datei bleiben die IDs. Dieselbe Quelle behält dieselbe ID. Eine neue Quelle bekommt die kleinste positive Zahl, die in der Liste noch fehlt.

| ID | Titel | Herausgeber | Fundstelle / URL | Fassung / Stand | Abgerufen |
|---|---|---|---|---|---|

Herausgeber ist die staatliche Stelle, nicht „Internet“. Fundstelle oder URL ist die geöffnete amtliche Stelle. Die Normstelle darf in dieser Tabelle stehen, nicht in den Wertetabellen. Fassung oder Stand nennt das Datum oder die Gesetzblattstelle, nicht nur „aktuell“. Abgerufen ist der Tag, an dem die Seite geöffnet wurde.

Jede ID im Text hat eine Zeile. Jede Zeile wird im Text genannt.

## Index

Nach dem Schreiben `references/directory-index.md` und `templates/index.md`. Die Zellen kommen aus dem Kopf: Bereich, Link mit Titel, Stichtag, Rechtsstand, `stand_recherche` als Zuletzt geprüft. Bei `uebersicht.md` ist der Rechtsstand `—`. Enthält ein Verzeichnis nur Unterverzeichnisse, die leere Dokumenttabelle weglassen.

## Prüfung

Nach dem Schreiben, aus dem Verzeichnis dieses Skills:

`python3 scripts/check.py --markdown` und die geschriebenen Dateien.

Status 0 ist die Voraussetzung für den Selbstcheck in `SKILL.md`. Die Ausgabe ist die mechanische Prüftabelle. Sie ersetzt nicht das Lesen der Beträge.
