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
- `stichtag` — `JJJJ-MM-TT`. Ein Jahr wird zu `JJJJ-01-01`
- `stand_recherche` — das Datum, an dem die Quellen in diesem Lauf geöffnet wurden. Nicht der Stichtag, solange nicht an diesem Tag recherchiert wurde
- `rechtsstand` — das Inkrafttreten der letzten berücksichtigten Änderung. Liegt nach dem Stichtag keine Änderung, ist es das Inkrafttreten der Fassung, die am Stichtag gilt. Dieses Datum steht in einer Quelle. Es wird nicht auf den Stichtag gesetzt, nur weil der Stichtag so lautet
- `berechnung` — `ja` oder `nein`

`berechnung` ist `ja` nur, wenn die Norm Geld oder eine Rechnung regelt und ein Beispiel vollständig aus Werten dieser Quellen gebaut werden kann. Gesetzliche Beträge, ein gesetzlicher Teiler wie 30 Tage und ein gesetzlicher Anteil reichen. Einkommen, Stunden oder ein Familienstand, den die Quelle nicht nennt, werden nicht erfunden. Fehlt ein solcher Wert, ist `berechnung` `nein` und der Abschnitt entfällt.

## Überschriften

Fest, in dieser Reihenfolge:

1. `Kurzüberblick`
2. `Rechtslage zum Stichtag TT.MM.JJJJ` — das Datum ausgeschrieben, passend zu `stichtag`
3. `Änderungen ab Stichtag`
4. `Beispielrechnung` — nur bei `berechnung: ja`
5. `Quellen`

Die Überschriften der dritten Ebene unter der Rechtslage in der Vorlage sind die Vorgabe für Leistungsarten: Anspruchsberechtigte, Voraussetzungen, Leistungsinhalt und Höhe, Verfahren und Fristen, Ausnahmen und Sonderfälle, Zusammenspiel mit anderen Leistungen. Bei einem anderen Gegenstand die dritte Ebene so benennen, dass sie den Gegenstand trifft, zum Beispiel Verpflichtete, Inhalt der Pflicht, Ausnahmen. Eine leere dritte Ebene weglassen. Eine dritte Ebene ohne Quelle nicht anlegen. Die zweite Ebene bleibt.

Die Chronik-Überschriften haben die Form `JJJJ-MM-TT – Kurztitel`. Das Datum ist das Inkrafttreten, damit es sortierbar ist. Der Kurztitel sagt in Klartext, was sich ändert, nicht das Aktenzeichen allein. Den Satz unter der Überschrift `Änderungen ab Stichtag` aus der Vorlage übernehmen, solange es Einträge gibt. Ein Eintrag beschreibt nur, was dieses Änderungsgesetz ändert. Die heutige Lesefassung nicht darunter nacherzählen. Dass etwas unverändert bleibt, höchstens ein kurzer Satz, und nur wenn die geöffnete Stelle das sagt.

Gibt es nach dem Stichtag keine gelesene Änderung, bleibt die Überschrift und ein Satz: in den geöffneten Quellen tritt nach diesem Datum keine Änderung in Kraft. Keine erfundene Überschrift `JJJJ-MM-TT`.

## Sätze und Tabellen

Zwei bis fünf Stichpunkte im Kurzüberblick: was es ist, wen es betrifft, wofür, die wichtigsten Eckwerte. Die Eckwerte stehen hier mit ihrer Zahl, nicht nur als Verweis auf eine spätere Tabelle.

Jeder sachliche Stichpunkt ist ein Satz in Klartext und endet mit der Quellen-ID: `[Q1]`. Mehrere Quellen: `[Q1][Q2]`. Dieselbe Aussage nicht unter einer zweiten Überschrift wiederholen. Eine Überleitung zu einer Tabelle („Die monatlichen Beträge:“) braucht keine ID, wenn die Tabelle selbst eine Quelle je Zeile nennt.

Keine Normstelle im Lauftext und nicht in den Tabellenzellen. Kein `§`, kein „Absatz 3 Satz 2“, kein Artikel als Zitat. Die Stelle steht in der Quellenliste, Spalte Fundstelle oder Fassung. „Pflegegrad 2“ oder „Grad 2“ bleibt, das ist der Begriff der Quelle, keine Fundstelle.

Zahlen, Schwellen, Anteile, Dauern und Vorher-nachher-Paare stehen in einer Tabelle, auch in der Chronik. Dieselbe Zahl darf im Kurzüberblick stehen, damit sie sofort sichtbar ist. In der Tabelle steht sie immer, in der Spalte Quelle als `[Q1]`.

Die Tabelle unter einem Chronikeintrag nur aufnehmen, wenn sich eine solche Größe ändert. Sie behält die drei Spalten der Vorlage. Die Quellen-ID steht am Stichpunkt, nicht in einer zusätzlichen Spalte. `Vorher` ist der Wert unmittelbar vor diesem Inkrafttreten, `Nachher` der neue Wert, beide aus geöffneten Texten. Eine leere Tabelle nicht anlegen.

Vollständig heißt: wer betroffen ist und wer nicht, welche Bedingung gilt, was geschuldet ist, in welcher Höhe und Dauer, welche Ausnahme, welches Verfahren, welches Zusammenspiel. Eine Ausnahme, eine Stufe oder eine Frist, die in der Quelle steht, fehlt nicht. „kann“ bleibt „kann“, „muss“ und „hat zu“ bleiben eine Pflicht, „auf Wunsch“ bleibt freiwillig.

Nicht der Gesetzestext im Wortlaut. Ein Stichpunkt, eine Aussage. Eine größere Änderung bekommt mehrere Stichpunkte.

Formbeispiel, keine Rechtsaussage:

Schlecht: „Gemäß § 4 Abs. 2 S. 1 beträgt die Leistung ggf. rund 200 Euro. Offene Punkte bleiben.“

Besser: „Personen mit Grad 2, die die Hilfe selbst sicherstellen, können die Leistung für einen vollen Kalendermonat erhalten [Q1].“ Die Höhe steht in der Tabelle, Zelle `200 Euro`, Quelle `Q1`.

Den Hinweis aus der Vorlage stehen lassen. Keine Rechtsberatung, kein Rat zu einem Einzelfall, kein Abschnitt „Offene Punkte“, kein „ungeprüft“. Platzhalter und HTML-Kommentare aus der Vorlage nicht mitnehmen.

## Beispielrechnung

Nur bei `berechnung: ja`. Annahmen, Rechenweg, Ergebnis. Jede Zahl kommt aus einer Quelle und trägt ihre ID. Keine Fallzahl erfinden, die die Norm nicht nennt, auch keine Anzahl von Tagen. Ein voller Monat mit dem gesetzlichen Betrag ist bestimmt. Ein Teiler oder ein Anteil wird nur angesetzt, wenn die Norm diese Rechnung nennt und die eingesetzten Zahlen aus ihr stammen. Eine Beispielrechnung zum Stand am Stichtag benutzt die Werte dieses Stands. Eine Rechnung zu einer späteren Fassung nennt deren Inkrafttreten und benutzt deren Werte.

## Quellen

Eine Liste. IDs `Q1`, `Q2`, … in der Reihenfolge der ersten Nennung, ohne Lücke und ohne Wiederverwendung.

| ID | Titel | Herausgeber | Fundstelle / URL | Fassung / Stand | Abgerufen |
|---|---|---|---|---|---|

Herausgeber ist die staatliche Stelle, nicht „Internet“. Fundstelle oder URL ist die geöffnete amtliche Stelle; die Normstelle steht hier, nicht im Lauftext. Fassung oder Stand nennt das Datum oder die Gesetzblattstelle, nicht nur „aktuell“. Abgerufen ist der Tag, an dem die Seite geöffnet wurde.

Jede ID im Text hat eine Zeile. Jede Zeile wird im Text genannt.

## Index

Nach dem Schreiben `references/directory-index.md` und `templates/index.md`. Die Zellen kommen aus dem Kopf: Bereich, Link mit Titel, Stichtag, Rechtsstand, `stand_recherche` als Zuletzt geprüft. Bei `uebersicht.md` ist der Rechtsstand `—`. Enthält ein Verzeichnis nur Unterverzeichnisse, die leere Dokumenttabelle weglassen.
