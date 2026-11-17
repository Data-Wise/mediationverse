# Plan: install provenance in sitrep()

Date: 2026-11-17 | Branch `feature/sitrep-provenance` off `dev` (0.2.0.9000)
Closes the one known limitation shipped in 0.2.0: `sitrep()` `source` is the
*recommended* source from the registry and is never detected from the installed copy.

## Evidence (this machine, `packageDescription()`)

- GitHub installs (pak/remotes): `RemoteType: github`, `RemoteHost`, `RemoteRepo`, `RemoteSha`.
- CRAN installs: `Repository: CRAN` (`RemoteType: standard`).
- Installs with none of these fields (load_all / local source installs): treated as `local`.
- RMediation here is a GitHub install, although the registry recommends CRAN. Provenance detection
  surfaces exactly this case.

## Design

- Internal, mockable `pkg_provenance(pkg)` in `R/provenance.R`: one of `CRAN`, `GitHub`,
  `r-universe`, `local`, `other`; `NA` when not installed or the description is unreadable.
- `mediationverse_sitrep()` result gains an `installed_from` column. `source` keeps its meaning
  (recommended source), so the change is additive.
- The hardcoded "CRAN status" prose (stale version numbers) is replaced by lines built from the
  registry and `installed_from`, with no literal version numbers.
- `checks = TRUE` gains a `source` check: warn when a member was installed from somewhere other than
  its recommended source. Warn, not fail (the minimum-version check already fails on bad versions).

## Tasks

1. `pkg_provenance()` + tests, including a real-install positive control (S).
2. `installed_from` column and report labels (M).
3. Replace the hardcoded CRAN-status block (S).
4. `source` check in `mv_checks()` (S).
5. NEWS, roxygen, `scripts/check-local.sh`, coverage >= 80% (S).

## Not in scope

- The ADHD status-dashboard proposal on `feature/adhd-friendly-status-dashboard` (atlas/README work).
  Its `.pkg_is_cran()` idea is subsumed by task 1.
