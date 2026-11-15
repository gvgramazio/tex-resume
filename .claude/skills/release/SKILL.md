---
name: release
description: Prepare a vitae release (version bump, changelog, tag). Use when asked to release, publish or bump the version.
---

# Release

1. Make sure you are on an up-to-date `master` and that `l3build check` and `scripts/build.sh -s` both pass.
2. Work out X.Y.Z from the Conventional Commits since the last tag (`git log $(git describe --tags --abbrev=0 2>/dev/null)..HEAD --oneline`). `feat!`/`BREAKING CHANGE` → major, `feat` → minor, everything else → patch. Before 1.0.0, a breaking change bumps the minor version.
3. Run `l3build tag X.Y.Z`. This rewrites `\ProvidesExpl...{date}{version}` in every `src/` file.
4. In `CHANGELOG.md`, move *Unreleased* to `## [X.Y.Z] - YYYY-MM-DD` and leave an empty *Unreleased* section.
5. Commit with the message `chore(release): vX.Y.Z` on a branch, and open a PR with the same title.
6. Once it is merged, **ask the user** before running `git tag vX.Y.Z && git push origin vX.Y.Z`. Pushing the tag triggers `.github/workflows/release.yml`, which publishes the release.
