---
name: f-legal
description: >
  Nimmt juristische Quellen (Gesetze, Verordnungen, staatliche Vorgaben) zu Deutschland und der EU auf,
  extrahiert developer-relevante Anforderungen und pflegt sie als strukturierte Markdown-Dokumente
  in docs/legal/. Verwende bei Anfragen zu rechtlichen Vorgaben, Compliance-Anforderungen,
  Gesetzesänderungen oder dem Aktualisieren regulatorischer Dokumentation für Berechnungs- oder
  Implementierungslogik. Nicht verwenden für allgemeine Rechtsberatung, das Ableiten von Anforderungen
  aus Code oder nicht-regulatorische Dokumentation.
---

# f-legal

Nimmt juristische Quellen auf, extrahiert developer-relevante Anforderungen und pflegt sie als strukturierte Markdown-Dokumente in `docs/legal/`.

## Zweck

Lightweight, agent-agnostischer Skill für regulatorische Dokumentation. Fokus auf Deutschland und EU.

Erstellt und pflegt:

- Eine Datei pro Leistungsart / unabhängig veränderbarem Regelungsbereich (z. B. `docs/legal/pflegeversicherung/pflegegeld.md`)
- Historie als klar getrennte Gültigkeitsabschnitte innerhalb derselben Datei
- Beispiele zur Übersetzung der Regeln in konkrete Berechnungslogik direkt im jeweiligen Gültigkeitsabschnitt
- Index-Dateien zur Übersicht

## Verhalten

1. Quelle entgegennehmen (URL, PDF, Text, Titel + Fundstelle, oder Hinweis auf bestehende Datei).
2. Relevanten Inhalt extrahieren und auf **berechnungs- und implementierungsrelevante Regeln** reduzieren. Siehe `references/extraction-guidelines.md`.
3. Passende Datei anlegen oder aktualisieren:
   - Neue Fassung als eigenen Abschnitt mit Datum einfügen (nicht bestehende Abschnitte überschreiben).
   - Beispielrechnung(en) direkt im jeweiligen Gültigkeitsabschnitt ergänzen.
   - Metadaten und Änderungshistorie aktualisieren.
4. In jedem angelegten oder aktualisierten Dokumentationsverzeichnis unter `docs/legal/` eine `index.md` anlegen oder aktualisieren. Befolge `references/directory-index.md` (dieselbe Regel wie die übrigen Skills, einschließlich aller Eltern unterhalb von `docs/`) und die Vorlage `templates/index.md`. Bei `docs/legal/pflegeversicherung/pflegegeld.md` sind also sowohl `docs/legal/pflegeversicherung/index.md` als auch `docs/legal/index.md` erforderlich.
   - Metadaten nur aus vorhandenen Dokumenten übernehmen.
   - In neuen Vorlagenkopien Platzhalter vollständig ersetzen; den Abschnitt `Unterverzeichnisse` weglassen, wenn keine vorhanden sind. Enthält das Verzeichnis nur Unterverzeichnisse, dann wird die leere Dokumenttabelle weggelassen.
5. Kurzer Report: was angelegt/aktualisiert wurde, Quellenangabe, betroffene Zeiträume.

## Regeln

- Dokumente in Deutsch, stark strukturiert (Tabellen, klare Abschnitte, konsistente Überschriften), damit Agents zuverlässig extrahieren können.
- Immer Quellenangabe und Gültigkeitszeitraum angeben.
- Historische Fassungen nicht löschen oder überschreiben – nur ergänzen.
- Keine juristische Beratung formulieren. Nur developer-relevante Anforderungen und Beispiele.
- Bevorzuge die kleinste Änderung, die die Anforderung erfüllt.
- AGENTS.md bleibt auf Englisch. Dieser Skill und die Dokumente in `docs/legal/` sind auf Deutsch, weil sie von Menschen und Agents gelesen werden.

## Ressourcen

- Vorlage für Dokumente: `templates/document.md`
- Vorlage für den Index: `templates/index.md`
- Verzeichnis-Index (gemeinsame Regel): `references/directory-index.md`
- Extraktionsregeln: `references/extraction-guidelines.md`

Lies die Vorlagen, bevor du eine neue Datei anlegst oder eine bestehende aktualisierst.

## Before you finish

- Jede Zahl, jeder Schwellenwert und jede Frist hat Quelle und Gültigkeitszeitraum.
- Eine neue Fassung steht als eigener Abschnitt; bestehende Abschnitte sind unverändert.
- Die Beispielrechnung liegt im passenden Gültigkeitsabschnitt und ist nachvollziehbar.
- Der rechtliche Hinweis steht im Dokument, `zuletzt_geprueft` ist gesetzt und der Index ist aktualisiert.
- Jedes betroffene Verzeichnis einschließlich aller Eltern bis `docs/legal/` hat eine aktuelle `index.md` gemäß `references/directory-index.md`. Die Einträge entsprechen den vorhandenen Inhalten und alle erzeugten relativen Links sind auflösbar.
