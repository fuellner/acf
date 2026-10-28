# Werkzeugkette im Container, eine Composer-Quelle

**Status:** accepted  
**Datum:** 2026-10-28

## Entscheidung

Die PHP-Werkzeuge von `f-refactor` werden nicht in das Anwendungsprojekt installiert. Sie laufen in einem eigenen Container. Derselbe Werkzeugsatz kann ohne Container in einem Verzeichnis außerhalb des Anwendungsrepositories liegen.

Die Anwendung behält ihre `composer.json`, ihre `composer.lock` und ihr `vendor/`. Ein altes PHP und ein Composer-Repository ohne packagist.org bleiben damit unangetastet.

Im Werkzeugprojekt gibt es genau eine Composer-Quelle. Voreinstellung ist `https://repo.packagist.org`. Eine interne Quelle ist erlaubt, nur über HTTPS, und nur wenn `packagist.org` in diesem Werkzeugprojekt ausgeschaltet ist. Paketnamen stehen auf einer festen Liste. Versionen sind `^MAJOR.MINOR`. Die `composer.lock` des Werkzeugprojekts ist verbindlich. Das Anlegen dieser Lock-Datei ist ein eigener, ausdrücklicher Schritt.

Das Basis-Image ist austauschbar, damit ein internes Registry-Spiegel verwendet werden kann. Voreinstellung ist das offizielle Image `php`, festgehalten über einen Digest. Der Lauf des Containers hat kein Netz, hängt den Anwendungscode nur lesend ein und schreibt Berichte in ein eigenes Verzeichnis. Rector und phpcbf liefern nur einen Diff. Übernehmen tut ihn ein späterer, geprüfter Schritt oder ein Mensch.

## Kontext

`composer require --dev` im Anwendungsprojekt scheitert in zwei Fällen. Das Anwendungsprojekt hängt an einem Composer-Repository, das packagist.org nicht anbietet. Und die Anwendung läuft auf PHP 5.3 oder einer anderen alten Version, während Rector 2, PHPStan 2 und Psalm 6 PHP 8 brauchen. Beides darf die Abhängigkeiten der Anwendung nicht verändern.

## Konsequenzen

- Installiert wird nur das Werkzeugprojekt, per Image-Build oder in das Verzeichnis außerhalb der Anwendung.
- Die Anwendung wird von diesen Skripten nicht verändert.
- 0004 und 0005 bleiben gültig.
