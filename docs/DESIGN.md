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

## 4. Paragraph spacing
- **Setting.** `parskip` takes a length and sets TeX's `\parskip`. The name follows the TeX length (and KOMA-Script's `parskip` option); vitae does not load the `parskip` package, which would also loosen template lines.
- **Structure stays fixed.** The header, section, entry and item groups run with `\parskip` = 0, so a template's lines keep their exact spacing under any setting. That includes user templates written with `\par`.
- **Bodies.** Blank lines in entry and item bodies are stored as `\__vitae_par:`, which ends the paragraph and adds the configured space with `\addvspace`. This works inside parboxes, lists and boxes, which reset `\parskip`, so every theme behaves the same.
- **Free text** (for example a Profile section) uses the global `\parskip`. The first paragraph after a heading therefore gets the heading's space plus `\parskip`, as in any `parskip`-based layout.

## 5. Dates
- **Input.** `start` and `end` are stored exactly as typed. Templates never print them directly: they always go through `\formatdate`, and ranges through `\daterange`.
- **Parsing.** `\formatdate` is expandable. It turns its trimmed input into a string, splits it at `-`, and accepts it only if it rebuilds exactly as `YYYY`, `YYYY-MM` (01–12) or `YYYY-MM-DD` (01–31; days aren't checked against the month). Anything else is returned unchanged.
- **Output.** `dateformat` (`long` | `short` | `numeric` | `iso` | `year`) picks a renderer. A year on its own is always printed as the year. Named styles take the month name from the locale's lists, and the day without its leading zero.
- **Locales.** Each locale stores month names, short names, a "present" word and four patterns (`ym`, `ymd`, `numeric-ym`, `numeric-ymd`) with `#1` year, `#2` month and `#3` day. The current locale is resolved when a date is formatted, from `datelocale` or else `\languagename`, through an alias table. Unknown locales fall back to English: there is a warning at `\begin{document}` for the main language, and when `datelocale` names one. The built-in locales are defined with the public `\vitaedatelocale`, starting from English, so users extend the class the same way the class does.
- **Scope.** Style, locale, separator and "present" are local variables. Preamble settings apply to the whole document, settings inside a group apply only to that group, and `dateformat`/`datelocale` entry keys apply to a single entry, because each entry is a group.
- **Layout.** Localised dates are long, so date columns must cope with labels that wrap. The default separator can break after the dash. The `modern` theme sets its hanging labels at zero depth, so a wrapped label doesn't push the body's lines down. If a label is taller than its body, the theme adds the missing space after the entry.
