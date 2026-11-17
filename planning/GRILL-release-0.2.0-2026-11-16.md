# GRILL: mediationverse 0.2.0

**Date**: 2026-11-16 | **Target**: `SPEC-release-0.2.0-2026-11-16.md` (first draft)
**Chain**: BRAINSTORM → SPEC (draft) → this GRILL + REVIEW → SPEC (revised)

| # | Question | Decision | Why |
|---|---|---|---|
| 1 | Separate `mediationverse_doctor()`? | **No: fold into `sitrep()`** | `sitrep()` already reports versions and sources; doctor's only new content is optional-dependency checks and fix hints. |
| 2 | How do the checks appear in `sitrep()`? | **Opt-in `checks = TRUE`**; default output unchanged, plus a one-line hint | Keeps existing output stable for scripts and tests. |
| 3 | Which new functions ship? | **`mediationverse_citations()` only**; `news()` deferred | Citations has a clear researcher use; `news()` mostly duplicates `utils::news()` and per-package pkgdown NEWS, and is fragile (see REVIEW 4). |
| 4 | Member list hardcoded in 4 files, no minimum versions | **Internal registry refactor first**, as its own behavior-neutral change | One source of truth for members, repos, minimum versions, optional deps. |
| 5 | Citation styles | **`"text"` and `"bibtex"`; no APA** | Base R has no APA formatter. |
| 6 | Test approach | **Injected helpers + content assertions; no snapshots** | Repo has zero snapshot tests; snapshots break when sibling versions change. |
| 7 | `include_self` default for citations | **`FALSE`** | Installed meta-package copy may be stale and embed a commit SHA. |

Carried from the brainstorm: `mv_options()` cut (no member reads `mediationverse.*` options).

## Not asked, defaulted

- Registry minimums: seed from each sibling's declared `Imports` constraint, with the
  medfit minimum set by the strictest dependent (missingmed `>= 0.3.1`). Verify when building.
- Release number: still 0.2.0 (new exports and a new `sitrep()` argument).
