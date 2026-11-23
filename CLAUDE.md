# CLAUDE.md

`vitae` is a LaTeX resume class. The class stores the content; `vitaetheme<name>.sty` files supply the look. The design is in `docs/DESIGN.md` (read it before you change the API); the user-facing reference is the manual, `docs/vitae-doc.tex`.

## Layout
- `src/`: `vitae.cls` (resume), `vitaeletter.cls` (cover letter), `vitaecore.sty` (code both share) and the themes. Only these files are shipped.
- `docs/`: `vitae-doc.tex` (user manual, l3doc, built by `l3build doc`), `sample-*.tex` (small complete vitae documents that the manual shows as source and cropped output), `DESIGN.md`.
- `testfiles/`: l3build regression tests (`.lvt` input, `.tlg` expected log).
- `examples/`: compilable documents, all built in CI in strict mode: `theme-*` (showcase), `letter-*` (cover letters), `stress-*` (layout edge cases), `accessible*` (PDF/UA), `archival-*` (one PDF/A recipe each), plus shared data in `examples/data/`. A `% engines:` header line limits engines; `% allow-warning:` exempts one known, harmless warning (justify it next to it).
- `scripts/build.sh`: compiles the examples (used by both CI and the `build` skill).
- `scripts/check-pdf.sh`: veraPDF (PDF/UA), text-extraction, link-action (`scripts/pdf-links.py`), active-content (`scripts/pdf-active.py`) and overprint (`scripts/pdf-overlap.py`) checks of built examples; `scripts/check-contrast.py`: WCAG contrast of theme colours. Both run in CI and need `pdftotext` (poppler) and `verapdf` locally.
- `scripts/junit.sh`: turns the last `l3build check` run into JUnit XML, which CI uploads to Codecov Test Analytics.
- `.github/workflows/codeql.yml`: CodeQL analysis of the workflows themselves (`actions` language).
- `.claude/skills/`: `build`, `test`, `new-theme`, `release`.

## Rules
- **Never put personal data in the repo.** Use invented names (Jane Doe), `example.com` and lorem ipsum.
- Every behaviour change needs an l3build test. Edge cases go in their own test file.
- Code must work on pdfLaTeX, XeLaTeX and LuaLaTeX. Keep the engine-specific code (fonts) in themes, behind `\sys_if_engine_pdftex:TF`. Tagged PDF is supported on LuaLaTeX; text extraction must stay clean on all three.
- Before you commit, run `l3build check`, `scripts/build.sh -s` and `scripts/check-pdf.sh`. All must pass.
- Every user-facing change updates the manual (`docs/vitae-doc.tex`), with a sample when the output is visual; the README only links to it. `l3build doc` must build it without errors.
- Work on a branch and merge through a PR. CI must be green to merge. Add an entry under *Unreleased* in `CHANGELOG.md`.
- In workflows, pin third-party actions (anything outside `actions/*` and `github/*`) to a full commit SHA with a `# vX.Y.Z` comment. Dependabot keeps the pins current, and CodeQL flags unpinned tags.
- Commit messages and PR titles follow [Conventional Commits](https://www.conventionalcommits.org): `feat:`, `fix:`, `docs:`, `test:`, `ci:`, `chore:`, `refactor:`. Mark breaking changes with `feat!:` or a `BREAKING CHANGE:` footer. The commit types determine the next version. Don't use emoji.

## Code style (all .cls/.sty)
- Write in expl3, using `\ProvidesExplClass` / `\ProvidesExplPackage`. Its version line is rewritten by `l3build tag`.
- File header: `%% <file> -- <purpose>.` followed by the license line.
- Sections: `% --- Title ---...` padded to column 76. Put a one-line comment above every non-trivial block.
- Naming: internal names are `\l__vitae_...`, `\g__vitae_...`, `\__vitae_...:n`. Public commands are plain document-level names, created with `\NewDocumentCommand`.
- Report problems with `\msg_new:nnn {vitae} {...}` and `\msg_error:nn`/`\msg_warning:nn`, never with raw `\errmessage`.
- Keep it terse: no dead code, no options nobody asked for.
- Templates never print raw dates. They always go through `\formatdate`/`\daterange`, which parse ISO input and localise the output (see DESIGN.md §7).
