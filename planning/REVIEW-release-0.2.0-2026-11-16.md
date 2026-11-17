# REVIEW: adversarial review of the 0.2.0 SPEC (first draft)

**Date**: 2026-11-16 | Independent subagent review; key claims spot-checked by the main session
(sitrep literals, empty RMediation citation, `news()` row shape, zero snapshot tests: all confirmed).

| # | Sev | Finding | Disposition |
|---|---|---|---|
| 1 | blocker | "Reuse sitrep internals / install-source map / minimum versions" is false: `R/sitrep.R:16-20` holds local literals, source is a CRAN-or-GitHub guess (`:54`), and no minimum versions exist. Member vector re-hardcoded in `packages.R`, `conflicts.R`, `update.R`. | Fixed: registry refactor first (GRILL 4). |
| 2 | blocker | `mediationverse_conflicts()` prints as a side effect, returns an unclassed empty data frame, defaults to `only_loaded = TRUE`. | Fixed: checks call an internal quiet finder with `only_loaded = FALSE`. |
| 3 | major | `citation("RMediation")` has length 0; source installs auto-generate "commit <sha>" citations. | Fixed: `tryCatch`, explicit empty-citation output, dev-SHA note. |
| 4 | major | `utils::news()` is one row per bullet (medfit: 36 rows, 10 versions); `n` ambiguous; ordering not guaranteed; NULL for unknown package. | `news()` deferred (GRILL 3). Revisit with `n` defined as versions. |
| 5 | major | lavaan is a hard Import of RMediation, so "optional dependency" is meaningless for it; only OpenMx (RMediation Suggests, `mbco()`) is truly optional. | Fixed: explicit dependency table in SPEC. |
| 6 | major | Test plan contradicts repo style: no snapshots exist, tests mock only `requireNamespace`; cli output is on the message stream; "plain fallback" is dead code since `cli` is in Imports. | Fixed (GRILL 6): helpers + content asserts. |
| 7 | major | `include_self` unspecified; installed self copy is stale 0.1.0 source install. | Fixed (GRILL 7). |
| 8 | minor | R-version check parses `Depends`; near useless (R >= 4.1.0). | Dropped. |
| 9 | minor | `all_ok` object shape unspecified. | Moot: doctor folded into `sitrep()`; `checks = TRUE` returns the existing report plus a `checks` data frame. |
| 10 | minor | Release drift: `_pkgdown.yml` index entry (else `check_pkgdown` fails), README lists 4 functions, `test-sitrep.R` pins "exactly 6", Roxygen pinned at 8.1.0, `.Rbuildignore`d planning docs. | Added to SPEC checklist. |
| 11 | minor | `citation()` has no APA style. | Fixed (GRILL 5). |
| 12 | minor | Value case thin: `citation("pkg")`/`news(package =)` exist; the delta is aggregation. | Accepted for citations; `news()` deferred. |
| 13 | minor | `getting-started.qmd` not built by `check-local.sh`. | Added: verify in CI. |
