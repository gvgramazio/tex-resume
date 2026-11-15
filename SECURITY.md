# Security policy

## Supported versions

Only the latest release receives fixes. Until 1.0, that means the latest `0.x` release.

| Version | Supported |
|---------|-----------|
| latest release | yes |
| older releases | no |

## Reporting a vulnerability

**Do not open a public issue.** Report privately through GitHub instead: on the [Security tab](https://github.com/gvgramazio/tex-resume/security), choose **Report a vulnerability**.

Please include:
- what is affected (the class, a theme, the CI workflows or a release artifact);
- how to reproduce it, ideally with a minimal document or workflow run;
- the impact you expect.

Use dummy data (Jane Doe, `example.com`) in any example. Never include a real resume.

This is a volunteer project maintained on a best-effort basis. You will get an acknowledgement as soon as possible, and a fix or an assessment will follow. Once a fix is released, the advisory is published with credit to you, unless you prefer to stay anonymous.

## Scope

In scope:
- `vitae.cls` and the `vitaetheme*.sty` files, for example a construct that runs shell commands or reads or writes files that the document didn't ask for;
- the GitHub Actions workflows, for example script injection or leaking secrets;
- release artifacts, for example a tampered package zip.

Out of scope:
- vulnerabilities in TeX engines, TeX distributions or third-party packages. Report those to their maintainers;
- documents compiled with `--shell-escape`. vitae never needs it, and enabling it grants the document arbitrary code execution by design.
