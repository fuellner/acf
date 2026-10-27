---
description: "Vorlage für regulatorische Dokumente in docs/legal/. Verwende diese Struktur beim Anlegen oder Aktualisieren einer Datei."
---

# Dokumentvorlage

Kopiere diese Struktur für jede neue Leistungsart / jeden Regelungsbereich.

```markdown
---
title: [Leistungsart / Regelungsbereich]
bereich: [z. B. Pflegeversicherung]
rechtsgrundlage: [z. B. SGB XI § 37]
quelle: [offizielle URL]
zuletzt_geprueft: YYYY-MM-DD
---

# [Leistungsart / Regelungsbereich]

> **Rechtlicher Hinweis:** Keine Rechtsberatung. Maßgeblich ist der veröffentlichte Gesetzestext in der angegebenen Fassung. Bei unklarer Auslegung ist eine Fachperson hinzuzuziehen.

## Kurzbeschreibung
[1–2 Sätze: Was regelt diese Leistungsart für den Berechnungsservice / die Implementierung?]

## Gültigkeitszeiträume

### Ab YYYY-MM-DD
**Quelle / Fassung**: [Link oder § + Datum der Fassung]

| Parameter | Wert | Voraussetzungen | Besonderheiten |
|-----------|------|-----------------|----------------|
| ...       | ...  | ...             | ...            |

**Relevante Anforderungen für die Berechnung**:
- ...
- ...

**Beispielrechnung**:
- Vorgabe: [konkrete Eingaben, Zeitraum]
- Berechnung: [Schritt-für-Schritt]
- Ergebnis: [Wert]
- Besonderheiten: [falls relevant]

### YYYY-MM-DD bis YYYY-MM-DD
[gleiche Struktur wie oben]

## Hinweise für Agents
- Bei Vorgängen im Zeitraum X–Y die Regeln aus dem entsprechenden Abschnitt verwenden.
- Beträge und Schwellenwerte immer aus der zum Vorgangsdatum gültigen Fassung nehmen.
- [weitere projektspezifische Hinweise]

## Änderungshistorie
- YYYY-MM-DD: Initiale Aufnahme
- YYYY-MM-DD: [kurze Beschreibung der Änderung]
```

## Hinweise zur Verwendung

- Das Verhalten beim Aktualisieren (neue Fassung als eigener Abschnitt, Historie nicht überschreiben, Beispiele im zugehörigen Gültigkeitsabschnitt) ist in `SKILL.md` (Verhalten, Schritt 3) geregelt; dort gültigen Wortlaut verwenden.
- Neue Fassungen oben einfügen (neueste zuerst), passend zur gezeigten Abschnittsstruktur.
- Tabellen für Zahlenwerte und Schwellenwerte bevorzugen.
