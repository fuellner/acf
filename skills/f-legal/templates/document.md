---
description: "Vorlage für eine Datei je Gegenstand unter docs/legal/. Kopiere den Block, ersetze die Platzhalter, übernimm die Kommentare nicht."
---

# Dokumentvorlage

Kopiere den Block nach `docs/legal/<bereich>/<gegenstand>.md`. Die Überschriften der zweiten Ebene bleiben. Die der dritten Ebene unter der Rechtslage sind die Vorgabe für Leistungsarten und werden bei anderen Gegenständen sachlich angepasst; eine leere Ebene entfällt. Beispielrechnung und Werte im Zeitverlauf nur übernehmen, wenn `berechnung` den Wert `ja` hat. Die Vorher-nachher-Tabelle nur, wenn sich eine Zahl, ein Schwellenwert oder eine Dauer ändert. Vor jeder Tabelle eine Leerzeile lassen. Regeln: `references/schreiben.md`.

```markdown
---
titel: <Gegenstand>
bereich: <bereich-slug>
gegenstand: <gegenstand-slug>
rechtsraum: DE
rechtsgrundlagen:
  - <Norm, Fassung>
stichtag: <JJJJ-MM-TT; bei Jahresangabe JJJJ-01-01>
stand_recherche: <JJJJ-MM-TT>
rechtsstand: <Inkrafttreten der letzten berücksichtigten Änderung>
aenderungen_geprueft_bis: <JJJJ-MM-TT>
berechnung: <ja | nein>
---

# <Titel>

> Zusammenfassung amtlicher Quellen, keine Rechtsberatung. Maßgeblich ist der Wortlaut der Quellen.

## Kurzüberblick

- <2 bis 5 Stichpunkte: was es ist, wen es betrifft, wofür, die wichtigsten Eckwerte> [Qn]

## Rechtslage zum Stichtag <TT.MM.JJJJ>

<!-- Dritte Ebene: Vorgabe für Leistungen. Sonst sachlich ersetzen. Leer weglassen. -->

### Anspruchsberechtigte

### Voraussetzungen

### Leistungsinhalt und Höhe

| Parameter | Wert | Bedingung | Quelle |
|---|---|---|---|

### Verfahren und Fristen

### Ausnahmen und Sonderfälle

### Zusammenspiel mit anderen Leistungen

## Änderungen ab Stichtag

Chronologisch, älteste zuerst. Datum = Inkrafttreten. Nur Änderungen, die nach dem Stichtag in Kraft treten.

### <JJJJ-MM-TT> – <Kurztitel der Änderung in Klartext>

- <was sich geändert hat, in Klartext> [Qn]

Gilt bis: <JJJJ-MM-TT oder unbefristet>

| Wert | Vorher | Nachher | Quelle |
|---|---|---|---|

## Werte im Zeitverlauf

<!-- Nur bei berechnung ja. Nur Werte aus der Rechtslage und der Chronik. -->

| Parameter | Ab | Wert | Bedingung | Quelle |
|---|---|---|---|---|

## Beispielrechnung

<!-- Nur bei berechnung ja. Annahmen, Rechenweg, Ergebnis. Nur belegte Werte. -->

## Quellen

| ID | Titel | Herausgeber | Fundstelle / URL | Fassung / Stand | Abgerufen |
|---|---|---|---|---|---|
```
