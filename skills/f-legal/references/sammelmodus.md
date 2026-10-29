# Sammelmodus

Lies diese Datei, wenn der Auftrag einen ganzen Bereich meint, zum Beispiel alle Leistungsarten eines Gesetzes. Sie ersetzt nicht `references/recherche.md` und `references/schreiben.md`. Beide gelten für die Übersicht und für jeden Gegenstand.

## Ablauf

1. Den amtlichen Text öffnen, der die Gegenstände des Bereichs aufzählt. Die Liste aus diesem Text bilden, nicht aus dem Gedächtnis. Ein Gegenstand, den die Quelle nicht führt, kommt nicht dazu.
2. Slugs festlegen. Zuerst `templates/uebersicht.md` nach `docs/legal/<bereich>/uebersicht.md` schreiben: welche Gegenstände belegt sind, je ein Satz, wie sie sich zueinander verhalten, Link auf die geplante Datei. Keine Betragstabellen aus den Gegenstandsdateien. Dieselben Quellenregeln. `stichtag` ist derselbe wie bei den Gegenständen.
3. Jeden belegten Gegenstand mit derselben Vorlage und denselben Regeln schreiben. Dieselbe Recherche, derselbe Stichtag, dieselbe Form. „Zusammenspiel mit anderen Leistungen“ verlinkt die benachbarte Datei relativ.
4. Wenn die Laufzeit die Gegenstände an getrennte Agenten geben kann, einen Gegenstand je Agent. Sonst nacheinander. Der Auftrag ist jedes Mal derselbe und enthält den vollständigen Wortlaut, nicht eine Zusammenfassung.
5. `python3 <Skill-Verzeichnis>/scripts/check.py --markdown <Pfad der Datei>` für die Übersicht und jede Gegenstandsdatei, nicht für `index.md`. Den aufgelösten Skriptpfad jedem Auftrag mitgeben. Kann ein Agent ihn nicht ausführen, führt ihn die führende Recherche selbst aus. Fehler korrigieren und wiederholen.
6. Danach alle Dateien selbst lesen und abgleichen. Den Abgleich nicht weggeben.
7. `index.md` einmal nachziehen, erst wenn die Dateien stehen. Nur diese führende Recherche schreibt den Index.

Lässt sich ein Gegenstand nicht belegen, keine Datei anlegen und keine Zeile in der Übersicht. Den fehlenden Gegenstand nur im Bericht nennen und nach der Fundstelle fragen. Die übrigen Gegenstände bleiben, wenn ihre eigenen Quellen gelesen sind.

## Auftrag an jeden Gegenstand

Der Auftrag nennt Gegenstand, Stichtag und Ausgabepfad und enthält danach, vollständig und unverändert:

- den Wortlaut von `references/recherche.md`
- den Wortlaut von `references/schreiben.md`
- den Wortlaut von `templates/document.md`

Keine kürzere Fassung an ihrer Stelle. Dazu nur diese Sätze: Werte nur aus geöffneten amtlichen Texten. Eine nicht belegbare Änderung dieser Vorschrift nicht schreiben, sondern die Fundstelle zurückmelden. `evals/` dieses Skills nicht als Rechtsquelle verwenden, außer die Nutzernachricht beschränkt diesen Lauf ausdrücklich darauf. Am Ende `python3 <aufgelöster Pfad>/scripts/check.py <Datei>` ausführen. Die führende Recherche setzt diesen Pfad ein.

## Abgleich

Die Quelle gewinnt. Nicht mitteln. Widersprechen sich zwei geöffnete Quellen, bleiben in den Dateien die jeweiligen Werte. Der Bericht nennt beide Zellen und fragt. Keine der beiden Dateien wird auf einen mittleren Wert gezogen.

Vor dem Vergleich `python3 <Skill-Verzeichnis>/scripts/check.py --markdown` und die Dateipfade. Danach diese Tabelle im Bericht, eine Zeile je Datei:

| Datei | Kopf | Überschriften | Normstelle | Quellen-IDs | Beträge |
|---|---|---|---|---|---|

Die ersten vier Ergebnisspalten kommen aus dem Skript. `Beträge` ist `ok` oder `Widerspruch`. Ein Widerspruch nennt Parameter, beide Werte und beide Dateien. Die Beträge werden aus den Tabellen gelesen, nicht aus dem Fließtext. Dieselbe Größe muss dieselbe Zahl und dieselbe Einheit haben.

Außerdem:

- Derselbe `stichtag` in der Übersicht und in jeder Gegenstandsdatei. Ein Jahr überall als 1. Januar aufgelöst.
- Dieselben Überschriften der zweiten Ebene. `berechnung`, Werte im Zeitverlauf und die Beispielrechnung passen zusammen.
- Ein Begriff je Sache, der Begriff aus dem Gesetz.
- Was die Übersicht als Verhältnis nennt, sagen die betroffenen Dateien auch. Die Grenze ist dieselbe Zahl, oder der Bericht weist den Widerspruch aus.
- Jeder Link auf eine Gegenstandsdatei löst sich auf. Die Übersicht hat keine Zeile ohne Datei.
- „Zusammenspiel mit anderen Leistungen“ enthält den relativen Link auf die Nachbardatei.
