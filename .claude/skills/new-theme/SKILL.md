---
name: new-theme
description: Scaffold a new vitae theme (src/vitaetheme<name>.sty + showcase and stress examples) from an existing one. Use when asked to create, fork or add a theme.
---

# New theme

```sh
.claude/skills/new-theme/scripts/new-theme.sh <name> [base-theme]   # base defaults to classic
```

The script creates:
- `src/vitaetheme<name>.sty`: a copy of the base theme, with the package name and the `\__vitae_<base>_` internals renamed;
- `examples/theme-<name>.tex`: a showcase built from `examples/data/janedoe.tex`;
- `examples/stress-<name>.tex`: the edge cases from `examples/data/stress.tex`;
- `examples/letter-<name>.tex`: a cover letter (`vitaeletter`) from the same data.

It refuses to overwrite files that already exist.

Then:
1. Edit the templates in the new `.sty`. Change only what makes the theme different, and keep a comment on each block. Theme rules:
   - Set defaults with `\keys_set:nn { vitae / setup } {...}`, never `\vitaesetup`, so users' own settings still take precedence.
   - Load engine-specific fonts behind `\sys_if_engine_pdftex:TF`.
   - Emit a line only when its fields are set. Use `\iffield` so you never leave blank lines.
   - In expl3 code, `~` right after a control word is swallowed. Use `\c_space_tl` there.
   - Provide the letter templates `opening` and `closing`, so a cover letter matches the resume.
   - Provide the `entry/compact` and `entry/inline` styles as well as `entry`. Build lines with `\joinfields` and `\ifanyfield`, so missing fields leave no stray separators.
   - Accessibility: wrap the name and section titles in `\taggedheading{1|2}{…}`, drawn rules in `\decorative{…}`, and meaningful symbols in `\actualtext{<text>}{…}`. Theme colours used for text need 4.5:1 contrast (`scripts/check-contrast.py`): text on white by default; declare other pairs, such as text on a fill, with `% contrast: <text> on <background>` lines.
   - Fonts: pick fonts no other theme uses, so each theme shows a different look. Check that they extract cleanly on all engines (`scripts/check-pdf.sh`): some fonts extract hyphens as U+2011 on XeTeX.
   - Don't handle paragraph spacing in templates. The class runs templates with `\parskip` = 0 and spaces body paragraphs itself (the `parskip` setting).
2. Build with `scripts/build.sh -s examples/theme-<name>.tex examples/stress-<name>.tex examples/letter-<name>.tex` and check the PDFs visually (see the `build` skill). Then run `scripts/check-pdf.sh` for text extraction, and validate a tagged LuaLaTeX build of the showcase with veraPDF (see `examples/accessible.tex`).
3. Document the theme in the manual (`docs/vitae-doc.tex`, section "Themes and settings", with a `docs/sample-*.tex`), and add it to the CHANGELOG.

Theme rendering is covered by the strict example builds. Class behaviour is covered by l3build tests (see the `test` skill), which use probe templates and don't depend on any theme.
