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
| Entries | `\cventry{<keys>}{body}`. Keys: `title`, `org`, `location`, `start`, `end`, `date` (= start and end) |
| Items | `\cvitem{label}{text}` |
| Lists | `\addentry{list}{<keys>}{body}`, `\additem{list}{label}{text}`, `\printentries[heading]{list}` |
| Dates | `\daterange{start}{end}`, `\formatdate{date}` |
| Look | `\usetheme{name}`, `\vitaesetup{accent=…, present=…, datesep=…, photowidth=…}` |
| Templates | `\settemplate{header\|contact\|contactsep\|section\|entry\|item}{code}`, using `\field{f}` and `\iffield{f}{yes}{no}` inside |

Notes:
- **Dates** are printed exactly as typed. `\daterange` prints `start – end`. With no end it prints `start – Present`, and when both dates are equal it prints a single date.
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

CI runs the tests and builds every example in strict mode on each pull request. Pushing a tag `vX.Y.Z` publishes a release with the package zip and the example PDFs. Design notes are in [docs/DESIGN.md](docs/DESIGN.md).

## License

MIT, see [LICENSE](LICENSE).
