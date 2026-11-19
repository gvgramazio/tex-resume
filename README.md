# vitae

A LaTeX class for resumes. You declare your data once, and a theme decides how it looks, in the same way beamer separates content from themes. It works with pdfLaTeX, XeLaTeX and LuaLaTeX.

**[User manual (PDF)](https://github.com/gvgramazio/tex-resume/releases/latest/download/vitae-doc.pdf)**: every command, setting and template, with examples.

## Quick start

```latex
\documentclass{vitae}          % options go to article: a4paper, 11pt, letterpaper, ...
\usetheme{modern}              % classic (default) or modern
\name{Jane}{Doe}
\jobtitle{Research Software Engineer}
\email{jane.doe@example.com}
\github{jdoe-example}

\addentry{experience}{title=Engineer, org=Lorem Ltd., location=Springfield, start=2021-04}{%
  Lorem ipsum dolor sit amet.}
\additem{skills}{Programming}{Lorem, Ipsum}

\begin{document}
\makeheader
\printentries[Experience]{experience}
\printentries[Skills]{skills}
\end{document}
```

More complete documents are in [examples/](examples/).

## Features

- **Data apart from layout:** named lists of entries and items, printed in any order, any number of times.
- **Themes and templates:** two themes (`classic`, `modern`); any template can be overridden, and entries come in `full`, `compact` and `inline` styles.
- **Dates:** ISO or free text, localised styles that follow babel and polyglossia, and durations ("2 yrs 7 mos").
- **Reaching readers:** text that applicant-tracking systems extract cleanly on every engine; accessible PDF/UA and archival PDF/A with LuaLaTeX, validated in CI.

## Installation

Download `vitae-ctan.zip` from the [latest release](https://github.com/gvgramazio/tex-resume/releases/latest), and copy `vitae.cls` and the `vitaetheme*.sty` files next to your document or into your personal TeX tree (`~/texmf/tex/latex/vitae` on Linux, `~/Library/texmf/tex/latex/vitae` on macOS). From a clone of this repository, `l3build install` does the same. TeX Live 2022 or later is required.

## Development

Requires TeX Live 2022 or later. `l3build` and `latexmk` are included in TeX Live.

| Task | Command |
|------|---------|
| Run regression tests (all engines) | `l3build check` |
| Run one test | `l3build check <name>` |
| Accept new test output | `l3build save <name>` |
| Build examples into `build/examples/` | `scripts/build.sh [-e "pdf xe lua"] [-s]` |
| Build the manual into `docs/vitae-doc.pdf` | `l3build doc` |
| Check built PDFs (PDF/UA, text extraction; needs poppler and veraPDF) | `scripts/check-pdf.sh` |
| Check theme colour contrast (WCAG AA) | `scripts/check-contrast.py` |
| Bump version in sources | `l3build tag X.Y.Z` |

CI runs the tests, builds every example in strict mode and builds the manual on each pull request. Test results go to Codecov Test Analytics as a JUnit report (`scripts/junit.sh`); there is no line coverage, because TeX has no coverage tooling. CodeQL analyses the GitHub Actions workflows. Pushing a tag `vX.Y.Z` publishes a release with the package zip and the example PDFs. Design notes are in [docs/DESIGN.md](docs/DESIGN.md).

## License

MIT, see [LICENSE](LICENSE).
