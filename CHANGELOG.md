# Changelog

Format: [Keep a Changelog](https://keepachangelog.com); versions follow [SemVer](https://semver.org).

## [Unreleased]
### Added
- Regions: `\printentries[region=aside]` and the `region` environment route
  content to a part of the page, such as a sidebar, in reading order; themes
  declare the regions they place with `\vitaeplaceregions` and print them
  with `\useregion` (`\ifregionempty` tests one). Region content goes
  through the `.aux` file, so a theme can place it before the point where it
  is routed; a rerun is requested when it changes. Content for a region the
  theme does not place prints in place, with a warning.
- Aside column, a layout helper for themes (and documents with a layout of
  their own): `\vitaeasidecolumn{width=…, sep=…, side=…, order=…}` takes a
  column from the text block and `\placeaside` starts it, at the top of the
  page or below a masthead; it continues on the next pages, which are added
  if it outlasts main. It holds the new `aside` template (by default the
  aside region). Under tagging it is an `Aside` structure element, read
  after main by default.
- Development: `scripts/check-pdf.sh` also checks that no two words of any
  example overlap (`scripts/pdf-overlap.py`) and that the aside stress
  examples print every part of their column once.
- `\makemasthead` and the `masthead` template, the new names of
  `\makeheader` and the `header` template for the identity block (name, job
  title, contacts, photo).

### Deprecated
- `\makeheader` and the `header` template: they still work, with a warning.
  In LaTeX a header is the running page header, so vitae keeps the word for
  that and calls the identity block the masthead.

### Fixed
- PDFs no longer have an `/OpenAction` in the catalog (hyperref's default
  start view), which made applicant tracking systems such as SAP
  SuccessFactors reject them as having active content. The viewer now opens
  them at its own zoom; `\hypersetup{pdfstartpage=1, pdfstartview=Fit}`
  restores the old behaviour.

## [0.5.0] - 2026-11-22
### Added
- `vitaeletter`, a cover-letter class that shares the resume's data, header,
  themes and settings: `\recipient`, `\letterdate` (an ISO date, localised
  through `\formatdate`; default the day of compilation), `\opening` and
  `\closing`, with themable `opening` and `closing` templates. A resume data
  file loads unchanged.
- Page footer: `\vitaesetup{footer={name, pages, updated}}` prints the name,
  "Page 2 of 3" and "Last updated …" (from the new `\lastupdated`), in the
  words of the date locale, through a themable `footer` template;
  `singlepagefooter=false` leaves it off one-page documents. Date locales
  take `pages` and `updated` patterns.

### Changed
- The code shared by both classes moved from `vitae.cls` into
  `vitaecore.sty`, which must be installed alongside the classes.

## [0.4.0] - 2026-11-22
### Added
- Durations: `\duration{start}{end}` gives the length of a range of ISO
  dates in the locale's units ("2 yrs 7 mos", "2 anni 7 mesi"); with
  `\vitaesetup{durations}`, `\printentries[durations]` or the entry key, the
  themes show it next to entry dates. `\vitaesetup{today=…}` fixes the end
  of ongoing ranges; date locales take `units`.
- `\printentries` treats a first option name without a value (such as
  `[durations]`) as an option rather than a heading.
- User manual, `vitae-doc.pdf` (`docs/vitae-doc.tex`, built by `l3build doc`):
  every command, setting, template and recipe, with compiled samples shown
  as source beside their output. CI builds it; releases and the package zip
  ship it.

### Changed
- The README is a short front page that links to the manual.

## [0.3.0] - 2026-11-19
### Added
- `parskip` setting: space between paragraphs of free text and of entry and
  item bodies (default `0.5\baselineskip plus 2pt`; `0pt` disables it).
- Entry styles: `compact` and `inline` alongside the default `full`, chosen
  per list (`\printentries[style=…]`) or per entry (`style` key). Users can
  override them or define new ones with `\settemplate{entry/<name>}`.
- `\printentries` options as key=value (`heading`, `style`); a plain
  heading still works.
- Accessible output: with `\DocumentMetadata{tagging=on, pdfstandard=ua-2}` (or
  `ua-1` with `pdfversion=1.7`) on LuaLaTeX, vitae PDFs conform to PDF/UA-2 or
  PDF/UA-1: the name and section titles are headings, icons have replacement
  text, decoration is an artifact, the photo has alt text, and the document
  title is set. A warning is given if tagging is used on other engines.
- Archival output: PDF/A-4f + PDF/UA-2, PDF/A-3a + PDF/UA-1 and PDF/A-2a +
  PDF/UA-1 (LuaLaTeX), PDF/A-2u (pdfLaTeX, LuaLaTeX) and PDF/A-2b (all
  engines), with ready-made recipes in the README.
- Clean text extraction for applicant-tracking systems on every engine:
  contact icons extract as their label ("Email:", "GitHub:") and separators
  as "; ", and pdfTeX icon fonts get complete Unicode maps.
- `\addcontact[url=…, label=…]`.
- Template helpers: `\joinfields`, `\ifanyfield` and `\addpunct` for lines
  without stray punctuation; `\actualtext`, `\taggedheading` and
  `\decorative` for accessible output.
- Development: CI validates PDF/UA and every PDF/A recipe with veraPDF,
  checks extracted text, link actions and theme colour contrast
  (`scripts/check-pdf.sh`, `scripts/check-contrast.py`); examples
  `accessible*.tex` and `archival-*.tex`; `scripts/build.sh` honours
  `% engines:` and `% allow-warning:` header lines.

### Changed
- Paragraphs are now separated by default. Template lines are unaffected;
  `\vitaesetup{parskip=0pt}` restores the previous output.
- Contact icons extract as their label and PDFs carry a document title.

### Fixed
- The website, LinkedIn, GitHub and ORCID contact links were written as file
  links (GoToR to `<url>.pdf`) instead of web links; they now open the
  address. Present since 0.1.0.
- Lists in tagged documents no longer warn with LaTeX 2026-11 (explicit list
  indent instead of enumitem's `leftmargin=*`; the layout is unchanged).

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
