# Sammelmodus

Lies diese Datei, wenn der Auftrag einen ganzen Bereich meint, zum Beispiel alle Leistungsarten eines Gesetzes. Sie ersetzt nicht `references/recherche.md` und `references/schreiben.md`. Beide gelten für die Übersicht und für jeden Gegenstand.

## Ablauf

1. Den amtlichen Text öffnen, der die Gegenstände des Bereichs aufzählt. Die Liste aus diesem Text bilden, nicht aus dem Gedächtnis. Ein Gegenstand, den die Quelle nicht führt, kommt nicht dazu.
2. Slugs festlegen. Zuerst `templates/uebersicht.md` nach `docs/legal/<bereich>/uebersicht.md` schreiben: welche Gegenstände es gibt, je ein Satz, wie sie sich zueinander verhalten, Link auf die geplante Datei. Keine Betragstabellen aus den Gegenstandsdateien. Dieselben Quellenregeln. `stichtag` ist derselbe wie bei den Gegenständen.
3. Jeden Gegenstand mit derselben Vorlage `templates/document.md` und denselben Regeln schreiben. Dieselbe Recherche, derselbe Stichtag, dieselbe Form.
4. Wenn die Laufzeit die Gegenstände an getrennte Agenten geben kann, einen Gegenstand je Agent. Sonst nacheinander. Der Auftrag unten ist jedes Mal derselbe. Die Agenten wählen nicht eine eigene Form.
5. Danach alle Dateien selbst lesen und abgleichen. Den Abgleich nicht weggeben: er vergleicht die Dateien miteinander.
6. `index.md` einmal nachziehen, erst wenn die Dateien stehen. Nur diese führende Recherche schreibt den Index, damit nicht mehrere Agenten dieselbe Datei ändern.

Lässt sich ein Gegenstand nicht belegen, keine Datei mit vermuteten Werten anlegen. In der Übersicht die Zeile ohne Betrag und mit dem Hinweis, dass die Fundstelle nicht erreichbar war. Im Bericht fragen. Die übrigen Gegenstände bleiben, wenn ihre eigenen Quellen gelesen sind.

## Auftrag an jeden Gegenstand

Gegenstand, Stichtag, Ausgabepfad und dieser Auftrag gehören zusammen:

- Lies `SKILL.md`, `references/recherche.md`, `references/schreiben.md` und `templates/document.md`, wenn sie im Auftrag liegen. Sonst gilt der Text hier.
- Öffne die amtlichen Texte und lies sie. Werte nur daraus. Die Lesefassung ist nicht der Stand am Stichtag, solange sie die historische Fassung nicht selbst zeigt. Inkrafttreten aus dem Änderungsgesetz. Quelle nicht erreichbar: nicht schreiben, die Fundstelle zurückmelden.
- Eine Datei, die Vorlage, Deutsch, Kopf wie die Vorlage. Im Lauftext keine Normstelle, am Satzende die Quellen-ID. Werte in Tabellen. Beispielrechnung nur bei Geld oder Rechnung und nur aus belegten Werten. Kein Abschnitt „Offene Punkte“.
- `evals/` dieses Skills nicht als Rechtsquelle verwenden, außer die Nutzernachricht beschränkt diesen Lauf ausdrücklich darauf.

## Abgleich

Die Quelle gewinnt. Weicht die Übersicht von einer Gegenstandsdatei ab, wird die Datei korrigiert, die nicht zur Quelle passt. Nicht mitteln.

- Derselbe `stichtag` in der Übersicht und in jeder Gegenstandsdatei. Ein Jahr überall als 1. Januar aufgelöst.
- Dieselben Überschriften der zweiten Ebene. `berechnung` und das Vorhandensein der Beispielrechnung passen zusammen.
- Ein Begriff je Sache, der Begriff aus dem Gesetz. Nicht in einer Datei „Grad“ und in der anderen „Stufe“, wenn die Quelle nur eines von beiden benutzt.
- Dieselbe Größe, dieselbe Zahl, dieselbe Einheit. Ein Vorher-nachher-Wert stimmt mit der Datei überein, die dieselbe Änderung beschreibt.
- Was die Übersicht als Verhältnis nennt, sagen die betroffenen Dateien auch: nebeneinander möglich, ausgeschlossen oder nur bis zu einer Grenze. Die Grenze ist dieselbe Zahl.
- Jeder Link auf eine Gegenstandsdatei löst sich auf. Eine Zeile ohne Datei kommt nur vor, wenn die Fundstelle nicht erreichbar war, und nennt dann keinen Betrag.
