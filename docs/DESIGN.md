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
| F9 | Global options go through `\vitaesetup{accent=…, present=…, datesep=…, photowidth=…}` (key–value). User settings take precedence over theme defaults, whatever their order. |

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

## 4. Dates
- `start` and `end` are stored exactly as typed. Templates never print them directly. They always go through `\formatdate{<raw>}`, which currently returns its input unchanged.
- Ranges are built in a single place, `\daterange`: it prints `start – end`, falls back to `present` when `end` is missing, and prints a single date when start equals end.
- Future direction: `\vitaesetup{dateformat=iso|long|short|…}` will make `\formatdate` recognize `YYYY[-MM[-DD]]` and render it in the chosen style. Any string that isn't ISO will still pass through unchanged, so existing documents keep compiling.
- Tests pin today's plain-string output, so a later change to date formatting can't silently alter existing documents.
