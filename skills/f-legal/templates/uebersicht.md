---
description: "Vorlage für die Übersicht eines Bereichs im Sammelmodus. Kopiere den Block, ersetze die Platzhalter, übernimm die Kommentare nicht."
---

# Übersichtsvorlage

Kopiere den Block nach `docs/legal/<bereich>/uebersicht.md`. Zuerst schreiben, dann die Gegenstandsdateien. Keine Betragstabellen aus diesen Dateien. Eine Zeile ohne Datei nur, wenn die Fundstelle nicht erreichbar war; dann ohne Betrag. Regeln: `references/sammelmodus.md`.

```markdown
---
titel: <Bereich in Klartext>
bereich: <bereich-slug>
rechtsraum: DE
stichtag: <JJJJ-MM-TT; bei Jahresangabe JJJJ-01-01>
stand_recherche: <JJJJ-MM-TT>
---

# <Titel>

> Zusammenfassung amtlicher Quellen, keine Rechtsberatung. Maßgeblich ist der Wortlaut der Quellen.

## Kurzüberblick
- <was der Bereich regelt und welche Gegenstände dazugehören> [Qn]

## Gegenstände
| Gegenstand | Worum es geht | Verhältnis zu den anderen | Datei |
|---|---|---|---|
| <Name> | <ein Satz> | <Abgrenzung oder Zusammenspiel> | [<slug>](<slug>.md) |

## Quellen
| ID | Titel | Herausgeber | Fundstelle / URL | Fassung / Stand | Abgerufen |
|---|---|---|---|---|---|
```
