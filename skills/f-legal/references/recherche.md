# Recherche

Lies diese Datei, bevor du eine Quelle auswertest. Sie legt fest, welcher Text gilt, wo er steht und wann du aufhörst.

## Was eine Quelle ist

Nur deutsches Recht. Bund und Länder. Nur Texte mit amtlichem Charakter, die eine deutsche staatliche Stelle herausgegeben hat.

Dazu gehören:

- das Bundesgesetzblatt auf recht.bund.de oder bgbl.de
- das Gesetz- und Verordnungsblatt eines Landes
- die Lesefassung auf gesetze-im-internet.de
- der Bundesanzeiger
- eine datierte Veröffentlichung eines Bundes- oder Landesministeriums oder einer anderen deutschen staatlichen Stelle, wenn sie den Normtext, einen Betrag oder eine amtliche Bekanntmachung trägt
- eine Drucksache des Bundestags oder Bundesrats mit der amtlichen Begründung
- eine Entscheidung eines Bundesgerichts aus einer amtlichen Entscheidungssammlung

Nicht dazu gehören, auch nicht als Beleg für eine Zahl: Kommentare, Lehrbücher, Kanzleiseiten, Blogs, Wikipedia, EUR-Lex und kommerzielle Sammlungen (zum Beispiel beck-online, juris, dejure, buzer). Eine solche Seite darf höchstens eine Fundstelle zeigen. Den Wert übernimmst du erst aus der amtlichen Stelle, die du selbst geöffnet hast.

Entscheidungen von Bundesgerichten sind eine nachgeordnete Quelle für die Auslegung, nie die Quelle eines Betrags, eines Schwellenwerts, einer Dauer oder eines Inkrafttretens. Steht die Zahl in der Norm oder in der Bekanntmachung, die sie festsetzt, kommt sie dorther. Das Urteil erklärt höchstens, wie eine Bedingung zu lesen ist, wenn der Normtext das offenlässt. Es wird kein Chronikeintrag. Landesgerichte und kommerzielle Urteilsdatenbanken bleiben draußen.

Setzt ein deutsches Gesetz Unionsrecht um, ist das verkündete deutsche Gesetz die Quelle, nicht der Unionsakt. Österreich und die Schweiz sind außerhalb, auch wenn der Text deutsch ist.

Anwendungscode ist keine Rechtsquelle. Diesen Skill nicht benutzen, um Code zu prüfen oder zu ändern.

Vorlagen, Referenzen, Skripte und `evals/` dieses Skills sind keine Rechtsquellen.

## Fundorte

Die Lesefassung ist die Karte. Der Wortlaut einer Änderung steht im Gesetzblatt. Die Materialien stehen im Dokumentations- und Informationssystem.

- Aktuelle Lesefassung: `https://www.gesetze-im-internet.de/<slug>/__<nummer>.html`. Die Seite zeigt den heutigen Text. Eine Fußnote der Form „Änderung durch Art. X G v. …“ ist nur der Verweis, nicht der alte Wortlaut.
- Bundesgesetzblatt ab 1. Januar 2023: `https://www.recht.bund.de/`. Die amtliche Verkündung ist dort die PDF. Ausgaben vor 2023 stehen dort nicht.
- Bundesgesetzblatt 1949 bis 2022: `https://www.bgbl.de/`. Das Archiv liegt oft nur im Dokumentenbetrachter oder als PDF.
- Vorgang und Drucksache: `https://dip.bundestag.de/`. Dort liegen Entwurf, Beschlussempfehlung und Gesetzesbeschluss.
- Amtliche Bekanntmachungen: `https://www.bundesanzeiger.de/`.
- Bundesgerichte: `https://www.rechtsprechung-im-internet.de/` und die eigene Seite des Gerichts, zum Beispiel `https://www.bundessozialgericht.de/`.

Kette, in dieser Reihenfolge:

1. Fußnote der Lesefassung lesen: „Änderung durch Art. X G v. …“ und die Gesetzblattstelle.
2. Diese Stelle öffnen. Ab 2023 auf recht.bund.de, davor auf bgbl.de.
3. Für die Begründung den Vorgang auf dip.bundestag.de öffnen und den Gesetzesbeschluss von der Begründung unterscheiden.
4. Den verkündeten Wortlaut aus dem Gesetzblatt übernehmen. Die Begründung erläutert. Sie setzt keine Zahl.

Liegt der Text nur als PDF vor, diese PDF öffnen und lesen, auch den Artikel über das Inkrafttreten. Eine HTML-Fassung einer nicht amtlichen Seite nicht als Ersatz nehmen. Lässt sich die PDF nicht öffnen oder nicht lesen, ist diese Fundstelle unerreichbar.

## Reihenfolge

Nur die betroffene Vorschrift nachzeichnen, nicht das ganze Gesetz seit seiner Erstverkündung.

1. Die Vorschrift in der aktuellen Lesefassung öffnen und nur als Karte benutzen: Fußnoten, Neubekanntmachung, Gesetzblattstellen. Den Wortlaut dieser Seite nicht als Stand am Stichtag behandeln.
2. Die letzte amtliche Neubekanntmachung suchen, deren Datum am Stichtag schon liegt. Sie ist der Anker. Gibt es keine, ist der Anker die verkündete Stammfassung dieser Vorschrift.
3. Nur die Änderungen dieser Vorschrift öffnen, deren Inkrafttreten nach dem Anker und bis einschließlich des Stichtags liegt. Den dort gedruckten neuen Wortlaut übernehmen. Druckt ein Gesetz nur den geänderten Satz, den übrigen Text aus dem Anker und den dazwischen geöffneten Fassungen zusammensetzen. Keinen Satz aus der heutigen Lesefassung auffüllen.
4. Jede Änderung dieser Vorschrift öffnen, deren Inkrafttreten nach dem Stichtag liegt. Nicht bei der Lesefassung aufhören. Was nur im Änderungsgesetz steht und in der Lesefassung schon wieder fehlt, gehört trotzdem in die Chronik. Jede Fußnote der Lesefassung nach dem Stichtag abhaken: entweder Chronikeintrag oder, wenn sie eine andere Vorschrift trifft, nur im Bericht nennen.
5. Verordnungen, datierte Veröffentlichungen von Ministerien und Behörden und amtliche Bekanntmachungen suchen, die Betrag, Frist oder Verfahren dieser Vorschrift setzen. Eine datierte Veröffentlichung eines Ministeriums oder eine Bekanntmachung darf einen Betrag tragen. Setzt die geöffnete Norm oder die Bekanntmachung, die den Betrag festsetzt, eine andere Zahl, gilt dieser Text. Eine undatierte Umschreibung reicht nicht. Die Begründung ersetzt den verkündeten Text nicht.
6. `aenderungen_geprueft_bis` setzen: der Tag, bis zu dem du geprüft hast, ob eine weitere Änderung dieser Vorschrift existiert. Das ist `stand_recherche`, wenn die Fußnotenliste aktuell ist und jede relevante spätere Stelle geprüft wurde. Ist die Liste älter und darüber hinaus nichts geprüft, ist es der Stand dieser Liste. Der Tag liegt nicht vor der letzten aufgenommenen Änderung und nicht nach `stand_recherche`.
7. Erst danach schreiben.

## Inkrafttreten

Das Inkrafttreten steht im Änderungsgesetz, meist in einem eigenen Artikel. Das Datum auf dem Gesetzblatt, der Tag des Beschlusses und der Stand der Lesefassung sind es nicht.

Manches Gesetz setzt Teile an verschiedenen Tagen in Kraft. Den Artikel ganz lesen. Für diese Vorschrift gilt der Tag des Artikels, der sie ändert, nicht der Tag, an dem das Gesetz im Übrigen in Kraft tritt. Rückwirkung nur annehmen, wenn dieser Artikel sie ausspricht.

Was am Stichtag bereits gilt, einschließlich einer Änderung, die an diesem Tag in Kraft tritt, gehört in die Rechtslage. Die Chronik beginnt mit dem nächsten Inkrafttreten danach. Sortiert wird nach Inkrafttreten, älteste zuerst. Teilen sich zwei Gesetze denselben Tag, steht das früher verkündete zuerst. Zwei Artikel desselben Gesetzes mit demselben Tag sind ein Eintrag. Zwei Artikel desselben Gesetzes mit verschiedenen Tagen sind zwei Einträge und dieselbe Quellen-ID.

Eine Befristung, die schon im Text am Stichtag steht, bleibt in der Rechtslage. Daraus wird kein eigener Chronikeintrag, solange kein späteres Gesetz etwas ändert. Eine Regel, die nach dem Stichtag in Kraft tritt und heute nicht mehr in der Lesefassung steht, ist ein Chronikeintrag. Anfang und Ende aus dem Änderungsgesetz übernehmen.

## Nicht zurückrechnen

Falsch: Die heutige Lesefassung nennt Betrag A und eine Videoregel. Für einen früheren Stichtag streichst du die Videoregel, gehst bis zur Erstverkündung zurück und setzt einen Betrag, an den du dich erinnerst.

Richtig: Du nimmst die letzte Neubekanntmachung vor dem Stichtag und nur die danach verkündeten Änderungen dieser Vorschrift. Der dort gedruckte Betrag B ist der Stand am Stichtag. Die Videoregel steht in einem späteren Änderungsgesetz und gehört in die Chronik, mit dem Inkrafttreten des Artikels, der sie einfügt. Eine befristete Sonderregel, die die Lesefassung nicht mehr abdruckt, steht im Änderungsgesetz dazwischen und gehört in die Chronik, wenn sie nach dem Stichtag in Kraft getreten ist.

Jeder Betrag, jeder Schwellenwert und jede Dauer wird so übernommen, wie die geöffnete Stelle sie druckt, einschließlich der Einheit. Nicht runden, nicht umrechnen, kein „rund“ oder „etwa“ dazusetzen, keines streichen, das dort steht.

## Anhalten

Die Datei nicht schreiben und keinen vorläufigen Wert nennen, wenn der Wortlaut dieser Vorschrift am Stichtag nicht geöffnet werden kann oder eine Änderung dieser Vorschrift, die in die Rechtslage oder in die Chronik gehörte, nicht geöffnet werden kann.

Nicht anhalten, wenn eine Fußnote nur eine andere Vorschrift ändert und sich das dazu genannte Gesetzblatt nicht öffnet. Diese Fußnote im Bericht nennen, mit der Fundstelle und dem Grund, dass sie diese Vorschrift nicht trifft. Nichts davon ins Dokument schreiben.

Beim Anhalten einmal fragen. Nennen, welche Fundstelle fehlt, für welches Datum sie fehlt und was bereits geöffnet wurde.
