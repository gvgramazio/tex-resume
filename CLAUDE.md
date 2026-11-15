# CLAUDE.md

`vitae` is a LaTeX resume class. The class stores the content; `vitaetheme<name>.sty` files supply the look. The design and API are in `docs/DESIGN.md`. Read it before you change the API.

## Layout
- `src/`: `vitae.cls` and the themes. Only these files are shipped.
- `testfiles/`: l3build regression tests (`.lvt` input, `.tlg` expected log).
- `examples/`: compilable documents, all built in CI in strict mode: `theme-*` (showcase), `stress-*` (layout edge cases), plus shared data in `examples/data/`.
- `scripts/build.sh`: compiles the examples (used by both CI and the `build` skill).
- `scripts/junit.sh`: turns the last `l3build check` run into JUnit XML, which CI uploads to Codecov Test Analytics.
- `.github/workflows/codeql.yml`: CodeQL analysis of the workflows themselves (`actions` language).
- `.claude/skills/`: `build`, `test`, `new-theme`, `release`.

## Rules
- **Never put personal data in the repo.** Use invented names (Jane Doe), `example.com` and lorem ipsum.
- Every behaviour change needs an l3build test. Edge cases go in their own test file.
- Code must work on pdfLaTeX, XeLaTeX and LuaLaTeX. Keep the engine-specific code (fonts) in themes, behind `\iftutex`.
- Before you commit, run `l3build check` and `scripts/build.sh -s`. Both must pass.
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
- Dates are plain strings for now. Always print them through `\formatdate`/`\daterange` (see DESIGN.md §4).
