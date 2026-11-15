# vitae

A LaTeX class for resumes. You declare your data once in the preamble, and a theme decides how it looks, in the same way beamer separates content from themes. It works with pdfLaTeX, XeLaTeX and LuaLaTeX.

> Status: work in progress. See [docs/DESIGN.md](docs/DESIGN.md) for the API design.

## Development

Requires TeX Live 2022 or later. `l3build` and `latexmk` are included in TeX Live.

| Task | Command |
|------|---------|
| Run regression tests (all engines) | `l3build check` |
| Run one test | `l3build check <name>` |
| Accept new test output | `l3build save <name>` |
| Build examples into `build/examples/` | `scripts/build.sh [-e "pdf xe lua"] [-s]` |
| Bump version in sources | `l3build tag X.Y.Z` |

CI runs the tests and builds every example on each pull request. Pushing a tag `vX.Y.Z` publishes a release with the package zip and the example PDFs.

## License

MIT, see [LICENSE](LICENSE).
