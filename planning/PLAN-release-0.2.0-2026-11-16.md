# Implementation Plan: mediationverse 0.2.0

Source spec: [SPEC-release-0.2.0-2026-11-16.md](SPEC-release-0.2.0-2026-11-16.md)
Task list: [TODO-release-0.2.0-2026-11-16.md](TODO-release-0.2.0-2026-11-16.md)
Location note: `planning/` is used instead of the skill's default `tasks/` because it is already
`.Rbuildignore`d.

## Overview

Registry refactor is done (`917dfae`). Remaining: fix two Codex review findings, add
`mediationverse_citations()`, add `mediationverse_sitrep(checks = TRUE)`, then release prep.

## Architecture decisions

- Sequential, single session: tasks share `R/sitrep.R`, `README.md`, `NAMESPACE`, `_pkgdown.yml`,
  so parallel agents would conflict. Each task ends green and committable.
- Codex finding 2 (sitrep `source` is the recommendation, not provenance): keep the column name
  (public API and tests pin it), document it as the *recommended* source, and make the printed
  label say so. Real provenance detection is deferred.
- Conflicts reuse: extract an internal quiet `find_conflicts()` from `mediationverse_conflicts()`
  (REVIEW 2) before `checks` needs it; exported behavior stays identical.
- Test style: injected helpers (`pkg_citation()`, `pkg_installed()`, `pkg_version()`), content
  assertions, no snapshots.
- Roxygen: installed 8.1.1 vs pinned 8.1.0. After every `devtools::document()` revert the
  `Config/roxygen2/version` line in `DESCRIPTION`.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Relabeling `source` text breaks existing sitrep tests | Low | Run suite after T2; tests assert column values, not printed text |
| `document()` churns unrelated Rd files | Med | Check `git status` after each run; revert unrelated churn |
| `citation()` empty/erroring for some members | Med | `tryCatch` helper; test empty and erroring cases |
| Quarto vignette changes not exercised by `check-local.sh` | Low | Keep vignette edits out of scope; README only |

## Open questions

- Real install-provenance reporting (CRAN vs GitHub vs r-universe) for `sitrep()`: deferred.
