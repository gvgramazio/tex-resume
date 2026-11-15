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

## Pitfalls
- **Probe templates:** test class logic by redefining a template to log its fields, e.g. `\settemplate{entry}{\TYPE{[\field{title}][\field{dates}]}}`. That keeps tests independent of themes and engines.
- **Groups:** `\TEST{...}{...}` wraps its code in a group, so `\usetheme` (which loads a package) must run at the top level, between `\START` and `\END`.
- **Date separator:** the default `\,` expands into noise in `\TYPE`. Set `\vitaesetup{datesep=--}` in the test preamble.
- **Robust commands in output:** `\TYPE` breaks on robust commands such as `\textit` or `\textsuperscript` ("Unbalanced write"). Use `\typeout` for those lines.
- **Masked dates:** l3build masks anything shaped like `YYYY-MM-DD` in logs as `....-..-..`. The shape is still compared, but prefer `YYYY-MM` inputs when the digits matter.
- **Non-ASCII output:** pdfTeX logs UTF-8 bytes (`^^c3^^a4`), while XeTeX and LuaTeX log code points (`^^e4`). Save `<name>.xetex.tlg` and `<name>.luatex.tlg`.
- **Engine differences:** graphics and fonts log differently per engine. Keep those tests in a separate file and save `<name>.<engine>.tlg` for each engine.
- **Layout** (fonts, spacing, page breaks) is covered by `examples/stress-*.tex` built with `scripts/build.sh -s`, not by l3build.
