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

## Accessibility and ATS

Every vitae PDF extracts as clean text, which is what applicant-tracking systems (ATS) read: icons come out as their label (`Email: jane.doe@example.com`, `GitHub: jdoe-example`) and contacts never run together. That needs no setup.

For a tagged, accessible PDF that conforms to PDF/UA, make this the first line and compile with **LuaLaTeX**:

```latex
\DocumentMetadata{tagging=on, pdfstandard=ua-2, lang=en-US}   % PDF/UA-2 (PDF 2.0)
% or: \DocumentMetadata{tagging=on, pdfstandard=ua-1, pdfversion=1.7, lang=en-US}
\documentclass{vitae}
```

The name and section titles become headings, icons get replacement text, decoration is marked as such, the photo gets alt text, and the document title is set from `\name` and `\jobtitle`. CI validates both standards with veraPDF.

- **Engines:** tagging is supported with LuaLaTeX only. pdfLaTeX's tagging cannot see inside the boxes vitae layouts use, so vitae warns if tagging is on there. On XeLaTeX, icons are hidden from extracted text but their labels are omitted, because its PDF driver would place them out of order.
- **Labels:** built-in contacts are labelled in English. For extra contacts, write `\addcontact[url=…, label=Blog]{\faRss}{example.org/blog}`; without a label, the icon is simply hidden from extracted text. Brace values that contain `=` or `,`, e.g. `url={https://example.org/?a=1}`.
- **Your own templates:** wrap headings in `\taggedheading{<level>}{…}`, drawn decoration in `\decorative{…}`, and symbols that carry meaning in `\actualtext{<text>}{…}`.

## Archival PDF (PDF/A)

PDF/A is the ISO standard for long-term archiving, which some employers, job portals and public bodies require. Choose a recipe and make it the first line of the document. Every recipe below is validated with veraPDF in CI, using the `examples/archival-*.tex` files:

| Goal | First line | Engines |
|---|---|---|
| Archival + accessible, PDF 2.0 (newest) | `\DocumentMetadata{tagging=on, pdfstandard={a-4f,ua-2}, lang=en-US}` | LuaLaTeX |
| Archival + accessible, PDF 1.7 (widest support) | `\DocumentMetadata{tagging=on, tagging-setup={attach-css=false}, pdfstandard={a-2a,ua-1}, pdfversion=1.7, lang=en-US}` | LuaLaTeX |
| Archival + accessible, PDF 1.7, embedded files allowed | `\DocumentMetadata{tagging=on, pdfstandard={a-3a,ua-1}, pdfversion=1.7, lang=en-US}` | LuaLaTeX |
| Archival, all text as Unicode | `\DocumentMetadata{pdfstandard=a-2u, pdfversion=1.7, lang=en-US}` | pdfLaTeX, LuaLaTeX |
| Archival, visual fidelity only | `\DocumentMetadata{pdfstandard=a-2b, pdfversion=1.7, lang=en-US}` | all three |

Which to choose:
- **An "a" level** (accessible) if you can use LuaLaTeX. It is the only one that is also PDF/UA, which an application form may ask for.
- **PDF/A-4f + PDF/UA-2** needs no extra settings.
- **PDF/A-2a + PDF/UA-1** is accepted by the widest range of validators and portals.
- **2u or 2b** are for when tagging isn't possible.

Known limitations:
- **PDF/A-2 and PDF/A-3 need `pdfversion=1.7`.** LaTeX writes PDF 2.0 by default, which only PDF/A-4 accepts. The same goes for PDF/UA-1.
- **PDF/A-2 with tagging needs `attach-css=false`.** LaTeX's tagging embeds two HTML stylesheets for PDF-to-HTML conversion, and PDF/A-2 forbids embedded files that aren't themselves PDF/A. PDF/A-3 and PDF/A-4 allow them.
- **The "a" levels need tagging, so LuaLaTeX** (see the section above).
- **XeLaTeX can't reach PDF/A-2u:** its icon fonts lack a Unicode map (#32). LaTeX also warns there that XeTeX can't write interword spaces. That warning is harmless and appears for any `\DocumentMetadata` document.
- **PDF/A-1** (PDF 1.4, no transparency) is not tested.
- **Your own photo** should be a JPEG, a PNG or a PDF/A-compliant PDF. Images are embedded as they are, so a non-conforming PDF image breaks conformance.

## Commands

| Purpose | Commands |
|---------|----------|
| Identity | `\name{First}{Last}`, `\firstname`, `\lastname`, `\jobtitle`, `\photo{file}` |
| Contacts | `\email`, `\phone`, `\address`, `\homepage{example.com}`, `\linkedin{id}`, `\github{user}`, `\orcid{id}`, `\addcontact[url]{icon}{text}` or `\addcontact[url=…, label=…]{icon}{text}` |
| Read data | `\the<field>` (e.g. `\theemail`), `\ifvitaeset{<field>}{yes}{no}` |
| Header | `\makeheader`, `\printcontacts`, `\printphoto` |
| Entries | `\cventry{<keys>}{body}`. Keys: `title`, `org`, `location`, `start`, `end`, `date` (= start and end), `style`, `dateformat`, `datelocale` |
| Items | `\cvitem{label}{text}` |
| Lists | `\addentry{list}{<keys>}{body}`, `\additem{list}{label}{text}`, `\printentries[heading]{list}` or `\printentries[heading=…, style=…]{list}` |
| Dates | `\daterange{start}{end}`, `\formatdate{date}`, `\vitaedatelocale{name}{<keys>}` |
| Look | `\usetheme{name}`, `\vitaesetup{accent=…, dateformat=…, datelocale=…, present=…, datesep=…, parskip=…, photowidth=…}` |
| Templates | `\settemplate{header\|contact\|contactsep\|section\|entry\|entry/<style>\|item}{code}`, using `\field{f}`, `\iffield{f}{yes}{no}`, `\ifanyfield{f,…}{yes}{no}`, `\joinfields{sep}{f, f=\format, …}` and `\addpunct{.}` inside; `\taggedheading`, `\decorative` and `\actualtext` for accessible output |

Notes:
- **Dates**: write them as ISO (`2020`, `2020-03` or `2020-03-01`), or as any other text, such as `Spring 2020`. ISO dates are printed in the chosen style; anything else is printed exactly as typed.
  - `dateformat` styles: `long` (default; March 2020, March 1, 2020), `short` (Mar 2020), `numeric` (03/2020, 03/01/2020), `iso` (2020-03), `year` (2020). A year alone always prints as the year.
  - The language follows babel or polyglossia, including `\selectlanguage`. Built-in locales are `english` (US order), `british`, `italian`, `german`, `french` and `spanish`, with the usual babel aliases. Any other language falls back to English with a warning. `datelocale=<name>` forces a locale.
  - Add a locale with `\vitaedatelocale{<name>}{months={…}, short={…}, present=…, ym={#2 #1}, ymd={#3 #2 #1}, numeric-ym=…, numeric-ymd=…, aliases={…}}`. Patterns receive `#1` = year, `#2` = month, `#3` = day; keys you omit are taken from English.
  - Scope: in the preamble, settings apply to the whole document. Inside a group (`{…}`, an environment) they apply only there. As entry keys they apply to that entry alone.
  - `\daterange` prints `start – end`. With no end it prints `start – present`, where the word comes from the locale unless you set `present`. Equal dates print once.
- **Entry styles**: `full` (the default `entry` template), `compact` (one line: title, organisation, location, dates) and `inline` (a run-in paragraph, for talks or publications). Choose one per list with `\printentries[heading=Certifications, style=compact]{certs}`, or per entry with the `style` key, which wins over the list's. `\settemplate{entry/<name>}{…}` overrides a style or defines a new one. `\printentries[<text>]` without `=` is still a plain heading.
- **Paragraphs** are separated by `parskip` (default half a line; `parskip=0pt` turns it off). It applies to free text and to blank lines inside entry and item bodies, while the lines a template draws (title, organisation, header, section rule) keep their exact spacing. The setting is the TeX `\parskip` length; vitae does not load the `parskip` package.
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
| Check built PDFs (PDF/UA, text extraction; needs poppler and veraPDF) | `scripts/check-pdf.sh` |
| Check theme colour contrast (WCAG AA) | `scripts/check-contrast.py` |
| Bump version in sources | `l3build tag X.Y.Z` |

CI runs the tests and builds every example in strict mode on each pull request. Test results go to Codecov Test Analytics as a JUnit report (`scripts/junit.sh`); there is no line coverage, because TeX has no coverage tooling. CodeQL analyses the GitHub Actions workflows. Pushing a tag `vX.Y.Z` publishes a release with the package zip and the example PDFs. Design notes are in [docs/DESIGN.md](docs/DESIGN.md).

## License

MIT, see [LICENSE](LICENSE).
