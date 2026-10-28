# Migration und Refactor sind ein eigener Ablauf

**Status:** accepted  
**Datum:** 2026-10-27

## Entscheidung

`f-refactor` ist ein eigener Workflow neben `f-workflow`, kein Schritt darin.

Der Ablauf hat ein eigenes Phasenmenü: Bestand aufnehmen, priorisieren, Sicherheitsnetz, Plan, einen Schritt ausführen, Ausrollen, abschließen. Status, Phase und grober Aufwand stehen in `docs/refactor/`. Eine spätere Sitzung setzt dort auf, nicht im Chat.

`f-refactor` schreibt diese Dokumente und das Fachwissen in seinen Referenzen. Aufgaben kommen von `f-tasks`, Charakterisierungstests von `f-testing`, die verhaltensgleiche Prüfung von `f-code-review`, eine Bruchanalyse von `f-debug`, Architekturentscheidungen von `f-docs`. Die Codeänderung eines Schritts führt `f-implement` aus, auf Zuruf dieser Step-Phase ([0007](0007-implement-ohne-commit.md)). Dieselben Verfahren werden nicht ein zweites Mal beschrieben.

`f-workflow` übergibt nur. Feature- und Bugfix-Arbeit geht aus `f-refactor` zurück an `f-workflow`.

## Kontext

0004 legt einen Skill mit den Typen `migration` und `refactor` fest. Der erste Einbau hing den Plan danach wieder in den Feature-Zyklus. Dadurch sah die Migration wie ein optionaler Schritt aus, obwohl sie ein eigener, sicherheitsgetriebener Ablauf mit eigener Reihenfolge ist.

## Konsequenzen

- Das Menü von `f-workflow` führt `f-refactor` als getrennten Workflow, nicht unter den optionalen Skills.
- Der Index `docs/refactor/index.md` ist die übersichtsweite Fortschrittsliste, einschließlich Phase und Aufwand.
- Produktion ist für den Agenten tabu. Datenbankmigration, Staging, Abhängigkeitswechsel, Löschen und jedes Deploy brauchen eine menschliche Freigabe.
- 0004 bleibt gültig: ein Skill, zwei Typen, Verhalten bleibt gleich, Versionen kommen von php.net.
