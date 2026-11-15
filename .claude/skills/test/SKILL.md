---
name: test
description: Run, add or update l3build regression tests for vitae (testfiles/*.lvt + *.tlg). Use when changing class/theme behaviour, fixing a bug, or covering an edge case.
---

# Regression tests (l3build)

```sh
l3build check              # all tests, all engines (pdftex, xetex, luatex)
l3build check <name>       # one test
l3build check -e xetex     # one engine
```

When a test fails, the diff is in `build/test/<name>.<engine>.diff`.

## Add a test
1. Create `testfiles/<name>.lvt`. Name it after the behaviour, e.g. `daterange-present`.
   ```latex
   % <one-line purpose of the test>
   \documentclass{vitae}
   \input{regression-test}
   \START
   \TEST{<case>}{ ... \TYPE{...} or \showbox / \tl_show:N ... }
   \END
   ```
   - Check stored values with `\TYPE{\theemail}`, or with `\ExplSyntaxOn \tl_show:N ... \ExplSyntaxOff`.
   - Check layout with `\setbox0\hbox{...}\showbox0` (set `\showboxdepth`/`\showboxbreadth` to keep the output short).
   - An expected error simply appears in the log, so record it in the `.tlg`.
2. Run `l3build save <name>`. Read the generated `testfiles/<name>.tlg` and confirm it is **correct** behaviour, not just whatever the code currently outputs.
3. If an engine's output legitimately differs, run `l3build save -e <engine> <name>`. That creates `<name>.<engine>.tlg`.

If a `.tlg` changes, the change must be intended. Explain it in the commit message.
