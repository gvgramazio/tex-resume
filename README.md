# vitae

A LaTeX class for resumes. You declare your data once in the preamble, and a theme decides how it looks, in the same way beamer separates content from themes. It works with pdfLaTeX, XeLaTeX and LuaLaTeX.

## Quick start

```latex
\documentclass{vitae}          % options go to article: a4paper, 11pt, letterpaper, ...
\usetheme{modern}              % classic (default) or modern
\name{Jane}{Doe}
\jobtitle{Research Software Engineer}
\email{jane.doe@example.com}
\github{jdoe-example}

\addentry{experience}{title=Engineer, org=Lorem Ltd., location=Springfield, start=2021}{%
  Lorem ipsum dolor sit amet.}
\additem{skills}{Programming}{Lorem, Ipsum}

\begin{document}
\makeheader
\printentries[Experience]{experience}
\printentries[Skills]{skills}
\end{document}
```

See [examples/](examples/) for complete documents.

## Commands

| Purpose | Commands |
|---------|----------|
| Identity | `\name{First}{Last}`, `\firstname`, `\lastname`, `\jobtitle`, `\photo{file}` |
| Contacts | `\email`, `\phone`, `\address`, `\homepage{example.com}`, `\linkedin{id}`, `\github{user}`, `\orcid{id}`, `\addcontact[url]{icon}{text}` |
| Read data | `\the<field>` (e.g. `\theemail`), `\ifvitaeset{<field>}{yes}{no}` |
| Header | `\makeheader`, `\printcontacts`, `\printphoto` |
| Entries | `\cventry{<keys>}{body}`. Keys: `title`, `org`, `location`, `start`, `end`, `date` (= start and end), `dateformat`, `datelocale` |
| Items | `\cvitem{label}{text}` |
| Lists | `\addentry{list}{<keys>}{body}`, `\additem{list}{label}{text}`, `\printentries[heading]{list}` |
| Dates | `\daterange{start}{end}`, `\formatdate{date}`, `\vitaedatelocale{name}{<keys>}` |
| Look | `\usetheme{name}`, `\vitaesetup{accent=…, dateformat=…, datelocale=…, present=…, datesep=…, photowidth=…}` |
| Templates | `\settemplate{header\|contact\|contactsep\|section\|entry\|item}{code}`, using `\field{f}` and `\iffield{f}{yes}{no}` inside |

Notes:
- **Dates**: write them as ISO (`2020`, `2020-03` or `2020-03-01`), or as any other text, such as `Spring 2020`. ISO dates are printed in the chosen style; anything else is printed exactly as typed.
  - `dateformat` styles: `long` (default; March 2020, March 1, 2020), `short` (Mar 2020), `numeric` (03/2020, 03/01/2020), `iso` (2020-03), `year` (2020). A year alone always prints as the year.
  - The language follows babel or polyglossia, including `\selectlanguage`. Built-in locales are `english` (US order), `british`, `italian`, `german`, `french` and `spanish`, with the usual babel aliases. Any other language falls back to English with a warning. `datelocale=<name>` forces a locale.
  - Add a locale with `\vitaedatelocale{<name>}{months={…}, short={…}, present=…, ym={#2 #1}, ymd={#3 #2 #1}, numeric-ym=…, numeric-ymd=…, aliases={…}}`. Patterns receive `#1` = year, `#2` = month, `#3` = day; keys you omit are taken from English.
  - Scope: in the preamble, settings apply to the whole document. Inside a group (`{…}`, an environment) they apply only there. As entry keys they apply to that entry alone.
  - `\daterange` prints `start – end`. With no end it prints `start – present`, where the word comes from the locale unless you set `present`. Equal dates print once.
- **Contact values** (email, URLs, handles) can contain `_ & ~ #` as typed. `\_ \& \# \%` are also accepted, but a raw `%` starts a comment.
- **Empty lists:** `\printentries` prints its heading only if the list has entries. An empty list prints nothing and logs a warning.
- **Field order:** contacts appear in a fixed order (email, phone, address, homepage, LinkedIn, GitHub, ORCID), followed by any `\addcontact` entries.

## Development

Requires TeX Live 2022 or later. `l3build` and `latexmk` are included in TeX Live.

| Task | Command |
|------|---------|
| Run regression tests (all engines) | `l3build check` |
| Run one test | `l3build check <name>` |
| Accept new test output | `l3build save <name>` |
| Build examples into `build/examples/` | `scripts/build.sh [-e "pdf xe lua"] [-s]` |
| Bump version in sources | `l3build tag X.Y.Z` |

CI runs the tests and builds every example in strict mode on each pull request. Test results go to Codecov Test Analytics as a JUnit report (`scripts/junit.sh`); there is no line coverage, because TeX has no coverage tooling. CodeQL analyses the GitHub Actions workflows. Pushing a tag `vX.Y.Z` publishes a release with the package zip and the example PDFs. Design notes are in [docs/DESIGN.md](docs/DESIGN.md).

## License

MIT, see [LICENSE](LICENSE).
