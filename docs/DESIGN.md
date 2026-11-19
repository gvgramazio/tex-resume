# vitae — design

A LaTeX class for building resumes. It stores the content, and themes decide how it looks,
in the same way beamer splits content from themes.

## 1. Requirements

### Functional
| ID | Requirement |
|----|-------------|
| F1 | The preamble stores personal data in variables: `\name{First}{Last}`, `\jobtitle`, `\photo`, `\email`, `\phone`, `\address`, `\homepage`, `\linkedin`, `\github`, `\orcid`, plus a generic `\addcontact[url]{icon}{text}`. |
| F2 | Each variable can be read back with a getter (`\thefirstname`, `\theemail`, …) and tested with a conditional (`\ifvitaeset{email}{yes}{no}`). |
| F3 | `\makeheader` typesets the stored identity and contacts, much as `\maketitle` does. |
| F4 | Entries use key–value fields: `\cventry{title=…, org=…, location=…, start=…, end=…}{description}`. Every field is optional. |
| F5 | Entries can be **stored** under a list name (`\addentry{education}{…}{…}`) and **printed** later (`\printentries{education}`). This keeps the data separate from the order it's printed in. |
| F6 | One-line items handle skills, languages and the like: `\cvitem{label}{text}`, `\additem{list}{label}{text}`. |
| F7 | `\usetheme{name}` loads `vitaetheme<name>.sty`. A default theme is used if none is chosen. |
| F8 | Themes override named **templates** (`header`, `contact`, `contactsep`, `section`, `entry`, `item`). Users can override a single template with `\settemplate{entry}{…}` without writing a theme. |
| F9 | Global options go through `\vitaesetup{accent=…, dateformat=…, datelocale=…, present=…, datesep=…, photowidth=…}` (key–value). User settings take precedence over theme defaults, whatever their order. |

### Non-functional
| ID | Requirement |
|----|-------------|
| N1 | It compiles with pdfLaTeX, XeLaTeX and LuaLaTeX. The engine-specific parts (fonts) live only in themes, behind `\sys_if_engine_pdftex:TF`. |
| N2 | Code is written in expl3 (`l3keys`, `l3seq`, `l3tl`), which ships with the LaTeX kernel. The minimum format is LaTeX 2022-06-01. |
| N3 | Errors are clear: unknown key, unknown theme or printing an undefined list each raise a `vitae` error or warning, never a low-level TeX failure. |
| N4 | The repo holds no personal data. Examples use invented names and lorem ipsum. |
| N5 | Code stays small, each block has a comment, and the style is the same across every file. |

### Edge cases to cover with tests
Missing optional fields (no location, no end date, so it prints "present"); start equal to end (a single date); an empty or undefined list; unknown keys and themes; calling `\usetheme` twice; characters like `_ # % & ~` in emails and URLs; Unicode names on pdfLaTeX; no photo, or a missing photo file; long titles that wrap; page breaks between entries; `\makeheader` with only a name; all three engines.

## 2. Architecture

```
vitae.cls            core: options, data store, keys, list storage, templates, public API
vitaetheme<n>.sty    look: fonts, colors, template definitions (classic, modern)
```

**Data store.** Each scalar is stored as `\g__vitae_field_<f>_tl`, set by a generated setter `\<f>` and read by an expandable getter `\the<f>`. The fields are defined in two lists, so adding a field takes one line. *Text* fields (name, job title, address, phone) keep TeX markup. *String* fields (email, URLs, handles, photo) are stored as plain characters: `_ & ~ #` work as typed, and `\_ \& \# \%` are unescaped. They use normal arguments, not verbatim ones, so setters also work inside macros.

**Entries.** The `l3keys` family `vitae/entry` parses fields into token lists, then the class calls the `entry` template. Storing an entry appends the unexpanded call `\cventry{keys}{body}` to the sequence `\g__vitae_list_<name>_seq`. Printing maps over that sequence. So stored and direct entries go through exactly the same code.

**Templates.** Each template is a macro `\__vitae_template_<name>:`. Themes and users redefine it with `\settemplate`. Inside a template, fields are read with the expandable `\field{title}` and tested with `\iffield{title}{…}{…}`. Every writer sets fields inside a group, so values never leak from one item to the next. Themes set their defaults with `\keys_set:nn {vitae/setup}`, which isn't recorded, so the user's `\vitaesetup` keys are replayed after the theme loads and take precedence.

**Base class.** It loads `article` for page setup and sectioning, adds `geometry`, `hyperref`, `xcolor` and `fontawesome5` (icons, which work on all engines), and remaps `\section` to the `section` template.

**Themes.**
- `classic`: serif font, a centered header and a right-aligned date column.
- `modern`: sans-serif font, an accent color, a left-aligned header with icons and a date margin.

## 3. Repository and tooling

```
src/                  vitae.cls, vitaetheme*.sty (the only shipped files)
testfiles/            l3build regression tests (*.lvt + *.tlg), one per behaviour or edge case
examples/             compilable documents with dummy data, one per theme
scripts/build.sh      compiles the examples per engine; -s turns warnings into failures
build.lua             l3build config (engines: pdftex, xetex, luatex)
.github/workflows/    ci.yml: tests + examples on every PR and push to master
                      release.yml: on a vX.Y.Z tag, publish the package zip + example PDFs
.claude/skills/       build, test, new-theme, release
CLAUDE.md             contributor conventions: code style, naming, testing
```

`l3build` is the standard LaTeX test harness and comes with TeX Live. It compares each test's log against a reference on every engine, which catches regressions and confirms that the expected errors are raised.

## 4. Entry styles
- **Styles are templates.** Style `<s>` uses template `entry/<s>`; blank or `full` uses `entry`, so existing templates and documents are unchanged. Themes provide `entry/compact` and `entry/inline`. `\settemplate` accepts any `entry/<name>`, which lets users add styles. Other unknown template names are still errors.
- **Choosing.** The style is a local variable: `\printentries[style=…]` sets it for one call (the call is a group), and the entry key `style` sets it inside a single entry, so the entry's own style wins. A style without a template warns once per style and falls back to `entry`.
- **`\printentries` options.** The optional argument is parsed as key=value (`heading`, `style`) when it contains `=`, and is otherwise a plain heading, which keeps `\printentries[Experience]{work}` working. Filters (`only`, `except`) and sorting will add keys here.
- **Template helpers.** `\joinfields{<sep>}{title=\textbf, org, location}` prints only the fields that are set, each in its optional format, so templates leave no stray separators. `\ifanyfield` is its expandable test. `\addpunct{.}` adds punctuation unless the text already ends with sentence punctuation (space factor above 1000, as amsthm's `\@addpunct`; a word ending in a capital, such as "USA.", still gets a second period).

## 5. Accessibility and text extraction
- **Two readers.** Applicant-tracking systems read the plain text stream and ignore tags; assistive technology reads the tag structure. Both are served, whatever the engine and whether or not tagging is on.
- **No option in vitae.** Tagging is switched on by the document's `\DocumentMetadata` line, which LaTeX requires before `\documentclass`. Everything vitae controls is always on, because it has no downside.
- **Replacement text** (`\actualtext`) has two layers: marked-content ActualText (`accsupp`, passed as UTF-16 hex, the one encoding every driver writes faithfully) for plain extraction; and, under tagging, a `Span` structure element with the same ActualText, or an artifact if the text is empty. Contact icons use their label ("Email:"); separators read "; ". On XeTeX the text is left empty, because xdvipdfmx writes it where extraction reads it out of order.
- **Structure.** `\taggedheading` tags the name as H1 and section titles as H2 (headings are template paragraphs, so paragraph tagging is switched off around them). `\decorative` marks drawn decoration as an artifact. The photo carries alt text. The PDF title is the name plus job title, and viewers are asked to show it.
- **Fonts.** On pdfTeX, every Font Awesome glyph is mapped to its code point, scoped to the icon fonts with `tfm:<font>/<glyph>`: icons named `at`, `slash` and `plus` must not remap `@`, `/` and `+` in text fonts.
- **Engines.** Tagged output is validated on LuaTeX only. pdfTeX's tagging cannot follow content through the boxes the layouts are built from (parboxes, measured and unpacked boxes), so vitae warns there. LuaTeX tags per glyph and passes PDF/UA-1 and UA-2 for every example, the stress tests included.
- **Standards.** PDF/UA-2 (PDF 2.0) is the primary target; PDF/UA-1 also passes but needs `pdfversion=1.7`, because tagging defaults to PDF 2.0. WCAG is not a PDF standard; its design rules apply to themes, and CI checks theme colours for 4.5:1 contrast.
- **PDF/A.** vitae adds nothing PDF/A-specific: conformance comes from LaTeX's `\DocumentMetadata` plus what vitae already guarantees (Unicode text, tagging on LuaTeX, no unmapped glyphs on pdfTeX). CI validates one example per supported recipe: PDF/A-4f + UA-2, PDF/A-3a + UA-1 and PDF/A-2a + UA-1 on LuaTeX; PDF/A-2u on pdfTeX and LuaTeX; PDF/A-2b on all engines. Two LaTeX behaviours shape the recipes. LaTeX writes PDF 2.0 unless told otherwise, so PDF/A-2 and PDF/A-3 need `pdfversion=1.7`. And tagging embeds HTML stylesheets (`latex-list-css.html`, `latex-align-css.html`) as associated files, which PDF/A-2 forbids, so it needs tagpdf's `attach-css=false`. XeTeX's icon fonts carry no Unicode map, so PDF/A-2u fails there (#32).

## 6. Paragraph spacing
- **Setting.** `parskip` takes a length and sets TeX's `\parskip`. The name follows the TeX length (and KOMA-Script's `parskip` option); vitae does not load the `parskip` package, which would also loosen template lines.
- **Structure stays fixed.** The header, section, entry and item groups run with `\parskip` = 0, so a template's lines keep their exact spacing under any setting. That includes user templates written with `\par`.
- **Bodies.** Blank lines in entry and item bodies are stored as `\__vitae_par:`, which ends the paragraph and adds the configured space with `\addvspace`. This works inside parboxes, lists and boxes, which reset `\parskip`, so every theme behaves the same.
- **Free text** (for example a Profile section) uses the global `\parskip`. The first paragraph after a heading therefore gets the heading's space plus `\parskip`, as in any `parskip`-based layout.

## 7. Dates
- **Input.** `start` and `end` are stored exactly as typed. Templates never print them directly: they always go through `\formatdate`, and ranges through `\daterange`.
- **Parsing.** `\formatdate` is expandable. It turns its trimmed input into a string, splits it at `-`, and accepts it only if it rebuilds exactly as `YYYY`, `YYYY-MM` (01–12) or `YYYY-MM-DD` (01–31; days aren't checked against the month). Anything else is returned unchanged.
- **Output.** `dateformat` (`long` | `short` | `numeric` | `iso` | `year`) picks a renderer. A year on its own is always printed as the year. Named styles take the month name from the locale's lists, and the day without its leading zero.
- **Locales.** Each locale stores month names, short names, a "present" word and four patterns (`ym`, `ymd`, `numeric-ym`, `numeric-ymd`) with `#1` year, `#2` month and `#3` day. The current locale is resolved when a date is formatted, from `datelocale` or else `\languagename`, through an alias table. Unknown locales fall back to English: there is a warning at `\begin{document}` for the main language, and when `datelocale` names one. The built-in locales are defined with the public `\vitaedatelocale`, starting from English, so users extend the class the same way the class does.
- **Scope.** Style, locale, separator and "present" are local variables. Preamble settings apply to the whole document, settings inside a group apply only to that group, and `dateformat`/`datelocale` entry keys apply to a single entry, because each entry is a group.
- **Layout.** Localised dates are long, so date columns must cope with labels that wrap. The default separator can break after the dash. The `modern` theme sets its hanging labels at zero depth, so a wrapped label doesn't push the body's lines down. If a label is taller than its body, the theme adds the missing space after the entry.
- **Durations.** `\duration` reuses the ISO test (`\__vitae_date_if_iso:nTF`, which hands year, month and day to a continuation) and stays expandable. Months count inclusively, LinkedIn-style (Sep 2018 – Mar 2021 is 31 months), because entries name whole months. With a year-only date, the precision drops to whole years (`end − start`): spanning to the last month of the end year would inflate "2018 – 2021" to four years. "Today" defaults to the compilation date (`\c_sys_year_int`, `\c_sys_month_int`); `today=` fixes it for reproducible builds and tests. The `duration` field is filled only when durations are on, the start and end differ (so `date=` entries get none), and the length is positive. Its blankness can therefore be tested with `\iffield`, as for every other field.
