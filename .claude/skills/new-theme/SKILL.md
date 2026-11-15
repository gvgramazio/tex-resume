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
- `examples/stress-<name>.tex`: the edge cases from `examples/data/stress.tex`.

It refuses to overwrite files that already exist.

Then:
1. Edit the templates in the new `.sty`. Change only what makes the theme different, and keep a comment on each block. Theme rules:
   - Set defaults with `\keys_set:nn { vitae / setup } {...}`, never `\vitaesetup`, so users' own settings still take precedence.
   - Load engine-specific fonts behind `\sys_if_engine_pdftex:TF`.
   - Emit a line only when its fields are set. Use `\iffield` so you never leave blank lines.
   - In expl3 code, `~` right after a control word is swallowed. Use `\c_space_tl` there.
2. Build with `scripts/build.sh -s examples/theme-<name>.tex examples/stress-<name>.tex` and check both PDFs visually (see the `build` skill).
3. Add the theme to the README and CHANGELOG.

Theme rendering is covered by the strict example builds. Class behaviour is covered by l3build tests (see the `test` skill), which use probe templates and don't depend on any theme.
