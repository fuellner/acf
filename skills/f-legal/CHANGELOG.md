# Changelog

## 2026-10-27
- Index-Regel: Grammatikfehler behoben („dann wird die leere Dokumenttabelle weggelassen“).
- Dokumentvorlage: Einfügeregel auf neueste-ganz-oben festgelegt (passend zur gezeigten Struktur); die mit SKILL.md verdoppelten Verwendungsregeln sind durch einen Verweis auf „Verhalten, Schritt 3“ ersetzt.
- Extraktionsrichtlinien: der `ungeprüft`-Marker hat jetzt einen festen Ort im Dokument (beim betroffenen Punkt), statt nur definiert zu sein.

## 2026-10-26
- Index-Pflege verweist auf `references/directory-index.md` statt die gemeinsame Prozedur zu wiederholen. Vorlagenregeln für Platzhalter, leere Abschnitte und Metadaten bleiben hier.
- Dokumentvorlage liegt jetzt unter `templates/document.md` statt `references/document-template.md` (Konvention: Vorlagen gehören nach `templates/`).
- Einziger englischer Regelpunkt ins Deutsche übertragen.
- Index-Regeln sprachlich an die übrigen Skills angeglichen.
- `index.md` in jedem betroffenen Unterverzeichnis sowie allen Eltern bis `docs/legal/` verpflichtend; bestehende Inhalte und relative Links maßgeblich. Index-Vorlage für verschachtelte Verzeichnisse angepasst.
- `docs/legal/` inkl. Index liegt vollständig bei f-legal; Index-Vorlage ergänzt.
- Ungenutzte Frontmatter-Felder (`type`, `lifecycle`) entfernt.
- Rechtlicher Hinweis fest in der Dokumentvorlage; unklare Auslegung wird als `ungeprüft` markiert.
- "Before you finish"-Selbstcheck ergänzt.

## 2026-10-23
- Initial creation of f-legal skill
- Document template with per-period examples and history sections
- Extraction guidelines for developer-relevant requirements
