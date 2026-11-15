---
name: new-theme
description: Scaffold a new vitae theme (src/vitaetheme<name>.sty + example + test) from an existing one. Use when asked to create, fork or add a theme.
---

# New theme

```sh
.claude/skills/new-theme/scripts/new-theme.sh <name> [base-theme]   # base defaults to classic
```

The script creates:
- `src/vitaetheme<name>.sty`: a copy of the base theme with the package name changed;
- `examples/theme-<name>.tex`: the base theme's example, switched to the new theme;
- `testfiles/theme-<name>.lvt`: a test that loads the theme and typesets a sample.

It refuses to overwrite files that already exist.

Then:
1. Edit the templates in the new `.sty`. Change only what makes the theme different, and keep a comment on each block.
2. Build it with `scripts/build.sh -s examples/theme-<name>.tex` and check the PDF visually (see the `build` skill).
3. Run `l3build save theme-<name>` and review the `.tlg` (see the `test` skill).
4. Add the theme to the README and CHANGELOG.
