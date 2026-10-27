# Ein Skill für Migration und Refactor

**Status:** accepted  
**Datum:** 2026-10-27

## Entscheidung

Verhaltensbewahrende Änderungen am Zielrepository laufen über einen Skill, `f-refactor`. Jede Einheit trägt genau einen Typ: `migration` oder `refactor`.

- `migration` ändert Laufzeit, Framework oder Abhängigkeiten. Erlaubt sind nur Korrekturen, die das Upgrade erzwingt. Ziel einer PHP-Migration ist das zum Planungszeitpunkt von php.net als aktiv unterstützt geführte, gepatchte PHP-8-Release. Die konkrete Version wird in der Sitzung von php.net gelesen und nicht im Skill festgeschrieben.
- `refactor` ändert die Struktur auf der bestehenden Laufzeit. Ein Versionswechsel gehört nicht in denselben Schritt.

Beobachtbares Verhalten bleibt gleich. Gefundene Fehler werden festgehalten und nicht behoben. Jeder Schritt ist einzeln auslieferbar und zurücknehmbar. Arbeit des anderen Typs wird eine eigene Einheit.

## Kontext

Der Bestand umfasst große PHP-Codebasen von 5.3 bis 8.x, Phalcon, Laravel, Symfony und frameworklosen Code, mit lückenhaften Tests. Die Systeme bleiben unter regelmäßigen Releases in Produktion. Die sicherheitsgetriebene Migration auf ein unterstütztes PHP ist der vorrangige Pfad; strukturelles Aufräumen ist der zweite Typ desselben Ablaufs.

Zwei Skills würden Index, Status, Fortsetzen über Sitzungen hinweg und die Review-Regeln doppelt führen. Dieselbe Art von Kopie ist bei den Verzeichnisindex-Regeln bereits auseinandergelaufen.

## Konsequenzen

- Der Typ steht im Plan und in `docs/refactor/index.md` (`ID | Title | Type | Priority | Status | File`).
- `f-code-review` prüft bei diesen Einheiten Verhaltensgleichheit. Bei `migration` ist eine nicht erzwungene Änderung ein Befund, bei `refactor` ein Versionswechsel.
- `f-tasks` macht aus geplanten Schritten Tasks, ohne Schritte zusammenzuziehen oder den Typ zu wechseln.
- Versionen, die php.net weder als aktiv unterstützt noch als Security-only führt, gehen nicht in Produktion. Ein Security-only-Stand ist nur ein zeitweiser Produktionsschritt, wenn der User das Restrisiko akzeptiert.
- Die Ausführung eines Schritts darf Anwendungscode ändern. Der allgemeine Implementation-Schritt bleibt ohne eigenen Skill und nimmt keine Refactor- oder Migrationsaufgabe an.
