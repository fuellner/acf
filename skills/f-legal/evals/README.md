# Evals für f-legal

Zwei Prüfungen, beide ohne Laufzeit in diesem Repository. Ein Lauf startet mit frischem Kontext und nur diesem Skill.

`evals.json` prüft die Ausgabe. Form nach der Agent-Skills-Anleitung zum Bewerten der Ausgabe: `prompt`, `expected_output`, `files`, `assertions`. Jede Assertion hat `kind` `structure` oder `content`. Ein Fall besteht nur, wenn jede Assertion besteht. Bestehen alle Struktur-Assertions und eine Inhalts-Assertion nicht, ist der Fall fehlgeschlagen. Eine Überschrift ohne den richtigen Betrag, das richtige Datum oder die fehlende Sonderregel zählt nicht.

`trigger-queries.json` prüft die Beschreibung. Eine Anfrage mit `should_trigger: true` besteht, wenn der Skill geladen wird. Eine mit `false` besteht, wenn er nicht geladen wird. `split: train` darf eine spätere Änderung der Beschreibung anleiten. `split: validation` bleibt dabei außen vor.

Die Dateien unter `files/` sind Fixtures, keine amtlichen Texte und keine Werte für ein Zieldokument. Im Lauf gelten sie nur, weil der Prompt sie zur einzigen geöffneten Fundstelle erklärt.

Beim Benoten einen Beleg zitieren, aus der Ausgabe oder aus der Fixture. Ein Abschnittstitel ohne den sachlichen Inhalt ist kein Bestehen.

Schreibt ein Fall Dateien, muss `python3 skills/f-legal/scripts/check.py` auf diesen Dateien mit Status 0 enden. Das ist die Strukturprüfung für Kopf, Überschriften, Normstellen außerhalb der Quellenliste, Leerzeilen vor Tabellen und Quellen-IDs. Ein Status ungleich 0 ist ein Fehlschlag, auch wenn die übrigen Assertions dem Text nach passen.
