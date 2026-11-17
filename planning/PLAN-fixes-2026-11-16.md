# Plan: fix the two deferred Codex findings on PR #30

Date: 2026-11-16 | Parent plan: [PLAN-release-0.2.0-2026-11-16.md](PLAN-release-0.2.0-2026-11-16.md)
Status: approved; B done, A pending. Branch `claude/restore-342f7b` (PR #30), sequential, one commit per task.

## Issue A: documented install can select a medfit with known result-changing bugs

Codex (high): `DESCRIPTION` has `medfit (>= 0.2.0)` and no source, so a plain install resolves CRAN
0.3.2, which predates the 0.5.0 fixes. README now names `Data-Wise/medfit` (done, `28c7775`) but
package metadata does not enforce it.

New fact (verified 2026-11-16 via `gh api`): probmed 0.4.1, missingmed 0.10.0 and medsim 0.6.0 have
no `medfit@v0.3.0` pin in `Remotes:`. The NEWS 0.1.1 / SPEC rationale for keeping medfit out of
`Remotes:` is stale.

Decision to make: add `Data-Wise/medfit` to `Remotes:` only (recommended), or also raise the Imports
floor to `medfit (>= 0.5.0)`. Recommendation: Remotes only. The floor would make the package
uninstallable from CRAN until medfit >= 0.5.0 is on CRAN, and `sitrep(checks)` already warns below 0.5.0.

- [ ] **A1 (S) Verify resolution before changing anything.** `pak::pkg_deps()` on the current tree
  and on a copy with the Remotes entry: confirm medfit resolves from GitHub at >= 0.5.0 and that
  probmed/medrobust/medsim/missingmed still resolve without a version conflict. AC: recorded output.
- [ ] **A2 (XS) Add `Data-Wise/medfit` to `Remotes:`** (`DESCRIPTION`).
- [ ] **A3 (S) Correct stale statements:** SPEC "Out of scope" bullet, `.STATUS` CRAN-path notes, and
  a NEWS entry (dev section only; the 0.1.1 history stays as written). Drop the README/article
  `Data-Wise/medfit` workaround only if A1 shows plain `pak::pak("Data-Wise/mediationverse")` now
  resolves GitHub medfit; keep it for the r-universe/remotes paths otherwise.
- Risk: CI (R-CMD-check) resolves dependencies through Remotes; it will start using GitHub medfit
  instead of CRAN 0.3.2. Mitigation: watch PR #30 CI; revert A2 if it breaks.
- Release note: `Remotes:` entries must be dropped for CRAN anyway (already on the CRAN-path list).

## Issue B: conflict check can pass after skipping an installed-but-unloadable member

Codex (medium): `pkg_installed()` is `requireNamespace()`, FALSE for both absent and installed-but-
broken packages, so such a member is silently skipped.

Design: add a mockable `pkg_state(pkg)` returning `"absent"`, `"ok"` or `"broken"` (installed on disk
per `system.file(package = )` but `requireNamespace()` fails). Keep `pkg_installed()` and the public
`installed` columns unchanged (no public API change); use `pkg_state()` only in the checks.

- [x] **B1 (S) `pkg_state()` helper + tests** (`R/checks.R`, `tests/testthat/test-checks.R`).
- [x] **B2 (M) Use it in the checks.** A single `load` row (fail, names every broken member; pass otherwise) and `check_min_versions()` skips broken members (reported once by `load`). Broken members also join the incomplete-inspection warning in `check_conflicts()`. (Originally planned as a row per member.)
  Original wording: for each member that is
  broken ("installed but cannot be loaded"). `check_min_versions()` stops mislabeling a broken member
  as "not installed". `check_conflicts()` adds broken members to the incomplete-inspection warning.
  AC: tests for broken-only, broken plus conflicts, absent-is-not-broken, all-ok unchanged.
- [x] **B3 (XS) Docs:** NEWS bullet; remove the "known limitation" paragraph from the SPEC.

## Order and checkpoints

1. B1, B2, B3 (code, no CI dependency). Checkpoint: `devtools::test()`, `scripts/check-local.sh`, coverage >= 80%, commit.
2. A1 (read-only), then A2, A3. Checkpoint: CI on PR #30 green after push.
3. One more Codex adversarial review on the combined diff; stop when only edge cases remain.

## Not in scope

- Changing the public `installed` column semantics in `mediationverse_packages()`/`sitrep()`.
- Raising the medfit Imports floor.
