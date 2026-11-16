# Changelog

Format: [Keep a Changelog](https://keepachangelog.com); versions follow [SemVer](https://semver.org).

## [Unreleased]
### Added
- Accessible output: with `\DocumentMetadata{tagging=on, pdfstandard=ua-2}` (or
  `ua-1` with `pdfversion=1.7`) on LuaLaTeX, vitae PDFs conform to PDF/UA-2 or
  PDF/UA-1: the name and section titles are headings, icons have replacement
  text, decoration is an artifact, the photo has alt text, and the document
  title is set. A warning is given if tagging is used on other engines.
- Clean text extraction for applicant-tracking systems on every engine:
  contact icons extract as their label ("Email:", "GitHub:") and separators
  as "; ", and pdfTeX icon fonts get complete Unicode maps.
- `\actualtext`, `\taggedheading` and `\decorative` for templates;
  `\addcontact[url=…, label=…]`.
- CI: veraPDF validation (PDF/UA-1 and UA-2), text-extraction checks and
  WCAG contrast checks of theme colours (`scripts/check-pdf.sh`,
  `scripts/check-contrast.py`); `examples/accessible*.tex`.
- `scripts/build.sh` honours a `% engines: …` line in an example.
- Entry styles: `compact` and `inline` alongside the default `full`, chosen
  per list (`\printentries[style=…]`) or per entry (`style` key). Users can
  override them or define new ones with `\settemplate{entry/<name>}`.
- `\printentries` options as key=value (`heading`, `style`); a plain
  heading still works.
- Template helpers `\joinfields`, `\ifanyfield` and `\addpunct`.
- `parskip` setting: space between paragraphs of free text and of entry and
  item bodies (default `0.5\baselineskip plus 2pt`; `0pt` disables it).

### Changed
- Paragraphs are now separated by default. Template lines are unaffected;
  `\vitaesetup{parskip=0pt}` restores the previous output.

## [0.2.0] - 2026-11-15
### Added
- ISO dates (`YYYY`, `YYYY-MM`, `YYYY-MM-DD`) are formatted by `\formatdate` and
  `\daterange`. Any other text is printed unchanged.
- `dateformat` setting: `long` (default), `short`, `numeric`, `iso` or `year`. It applies
  to the whole document, to a group, or to a single entry (as an entry key).
- Localised date formats that follow babel or polyglossia, with the built-in locales
  `english`, `british`, `italian`, `german`, `french` and `spanish`.
  `datelocale` forces a locale, and `\vitaedatelocale` defines new ones.
- `examples/dates.tex`, plus date edge cases in the stress examples.

### Changed
- **Breaking:** `2020-03`-style dates now print as "March 2020" (or in the chosen
  style) instead of verbatim. `\vitaesetup{dateformat=iso}` restores the old output.
- "Present" follows the locale unless `present` is set.
- The default date separator allows a line break after the dash.
- `modern`: a date label that wraps no longer leaves a gap in the entry,
  and a label taller than its body no longer overlaps the next entry.


## [0.1.0] - 2026-11-15
### Added
- Repository skeleton: l3build tests, CI, release workflow, Claude skills.
- `vitae` class: personal data fields with getters, contacts, `\makeheader`,
  key-value entries, items, named lists, date ranges, templates and `\vitaesetup`.
- Themes `classic` and `modern`.
- Examples (showcase, minimal, custom template, edge-case stress tests) and
  regression tests for fields, dates, entries, lists, contacts, templates,
  photo and theme loading.
