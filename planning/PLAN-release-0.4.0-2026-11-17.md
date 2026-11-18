# Plan: mediationverse 0.4.0 (self-contained, executable without questions)

Status: **released** as 0.4.0 (tag `v0.4.0` at bc3643f, PRs #38 to #40).

Date: 2026-11-17 | Base: `dev` at 6fcd462 (0.3.0.9000; 0.3.0 released, tag `v0.3.0`).
Distribution: GitHub + r-universe, not CRAN (blockers unchanged in `.STATUS`).
Branch for the work: `feature/release-0.4.0` (this file is its first commit).

Theme: **know when your ecosystem is stale.** `sitrep()` already says where each member came from
(0.3.0); 0.4.0 says whether it is the latest one available from that source, and lets
`mediationverse_update()` act on that.

## 0. Evidence behind the scope

Measured 2026-11-17 on the dev machine (installed vs. latest on the member's recommended source):

| Member | Installed | Latest (r-universe) | Registry source |
|---|---|---|---|
| medfit | 0.7.0 | 0.18.0 | GitHub |
| probmed | 0.4.1 | 0.4.1 | GitHub |
| RMediation | 1.6.1 | 1.11.1 on r-universe; 1.6.1 on CRAN | CRAN |
| medrobust | 0.4.4 | 0.4.4 | GitHub |
| medsim | 0.5.1 | 0.6.0.9000 | GitHub |
| missingmed | 0.9.0.9000 | 0.10.0 | GitHub |

- Three of six members are behind, medfit by eleven minor versions, and nothing in `sitrep()` says so:
  every check passes because the registry floor (medfit 0.5.0) is far below the latest. This is the
  gap 0.4.0 closes.
- "Latest" must follow the registry `source`, or RMediation is always "outdated" against a version
  `mediationverse_update()` will never install (it installs from CRAN, 1.6.1). So: CRAN-recommended
  members compare against CRAN; GitHub-recommended members compare against r-universe.
- `https://data-wise.r-universe.dev/api/packages/<pkg>` answered in 0.19 s with a `Version` field
  (200). CRAN: `https://crandb.r-pkg.org/<pkg>` returns JSON with `Version`.
- No sibling package reads a `mediationverse.*` option (only medfit's own `medfit.*` options exist),
  so `mv_options()` stays out. medfit's API moved 0.7 to 0.18 in a month; `mediate()` /
  `mediation_pipeline()` would wrap a moving target, so they stay out of 0.4.0 and get a design
  document only (task 6).

## 1. Decisions made up front (no "TBD")

### 1.1 `pkg_latest(pkg, source)` — new file `R/latest.R`

```r
# Latest available version of one package from its recommended source, as a string, or NA when
# it cannot be determined (offline, timeout, bad response). Isolated so tests can mock it.
pkg_latest <- function(pkg, source)
```

- `source == "CRAN"`: GET `https://crandb.r-pkg.org/<pkg>`; `source == "GitHub"`: GET
  `https://data-wise.r-universe.dev/api/packages/<pkg>`. Both parse JSON field `Version`.
- Transport: base R only (no new Imports): `url()` + `readLines(warn = FALSE)` inside `tryCatch`, with
  `options(timeout = 5)` set via `on.exit`-restored local change. Parse JSON with a small regex for
  `"Version"\s*:\s*"([^"]+)"` (the two payloads are flat enough; jsonlite is not a dependency and must
  not become one). Any error, empty body or no match returns `NA_character_`. Never warns, never aborts.
- The package name is validated against `mv_all_packages()` before building a URL
  (`stopifnot`-free: unknown name returns `NA`), so no user text reaches a URL.
- Network happens only when the caller asks (1.2, 1.3); nothing at load time, nothing in tests.

### 1.2 `sitrep(updates = FALSE)`

- New argument `updates` (logical, default `FALSE`, validated with the same style as `checks`).
- When `TRUE`: for each installed core member call `pkg_latest(pkg, source)` once (registry `source`).
  Output data frame gains `latest` (character, `NA` when unknown or not installed) and `outdated`
  (logical; `TRUE` when both versions are known and `numeric_version(installed) < numeric_version(latest)`,
  `NA` when either is unknown). When `updates = FALSE` these two columns are absent, so the 0.3.0 shape
  is unchanged by default.
- Report line gains ` -> {latest} available` for outdated members only; an "Updates" section lists
  outdated members ("{pkg} {installed} -> {latest}") and ends with
  `Run mediationverse_update() to install.`, or says `All installed members are up to date.`;
  members with unknown latest are listed as `Could not check: ...` (offline is not an error).
- Without `updates = TRUE` the report prints one hint line: `Use sitrep(updates = TRUE) to check for newer versions.`

### 1.3 `check_updates()` — `sitrep(checks = TRUE, updates = TRUE)`

- New check row `updates` in `mv_checks()` (after `source`), present only when `updates = TRUE`
  (`mv_checks(updates = FALSE)` keeps the current five checks). `warn` when any member is outdated
  ("Newer versions available: medfit 0.7.0 -> 0.18.0, ..."), fix hint `mediationverse_update()`;
  `warn` with "Could not check for updates" when every lookup returned `NA`; `pass` otherwise.
  Never `fail`: an old version is not a broken one (the min-version check owns failures).

### 1.4 `mediationverse_update(only_outdated = FALSE, dry_run = FALSE)`

- `only_outdated`: when `TRUE`, restrict the package set (after the existing validation) to members for
  which `pkg_latest()` reports a newer version than installed; members not installed are always kept
  (they need installing); unknown latest keeps the member (safe default: install).
- `dry_run`: when `TRUE`, print the packages that would be installed, one line each with its source, call
  nothing, and return `invisible(packages)`.
- Existing behavior with default arguments is byte-for-byte unchanged (a regression test pins it).

### 1.5 Docs and hygiene

- `R/sitrep.R` roxygen documents `updates` and the new columns; `R/update.R` documents the two arguments;
  `README.md` gets a two-line example; `vignettes/getting-started.qmd` one sentence; `NEWS.md` bullets under
  `# mediationverse (development version)`; `.STATUS` done line.
- Roxygen pinned at 8.1.0 (installed 8.1.1): `git checkout DESCRIPTION` after every `devtools::document()`.
- No new dependencies in `DESCRIPTION`. `withr` is not declared: tests use a base-R option helper like
  `with_quiet()` in `test-startup.R`.

### 1.6 Design document (no code)

`planning/DESIGN-mediate-pipeline-2026-11-17.md`: what a `mediate()` / `mediation_pipeline()` would wrap
(`medfit::fit_mediation`, `extract_mediation`, `bootstrap_mediation`, `te/nde/nie/pm`), the current
argument surfaces read with `args()`, the version-skew risk (medfit 0.7.0 vs 0.18.0 in the wild), three
options (thin wrapper, S7 pipeline object, docs-only recipe) with a recommendation, and the exit criteria
for building it in a later release. Evidence for each claim comes from running `args()` and reading the
sibling NAMESPACE files in this session, not from memory.

## 2. Tasks (in order; one local commit each)

Conventions: tests first (write, see them fail, implement); testthat 3 style with
`local_mocked_bindings`; helpers named `mock_*` / `run_*`; `pkg::fun()` only; US English; commit trailer
`Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. No test may touch the network: every test
mocks `pkg_latest`.

1. **`pkg_latest()` (S)** — `R/latest.R`, `tests/testthat/test-latest.R`. Tests: parses CRAN-shaped JSON;
   parses r-universe-shaped JSON; returns `NA` on error / empty / no `Version`; returns `NA` for a name not in
   the registry without any connection attempt (mock `url` to fail the test if called); restores
   `options(timeout)`. To test parsing without a network, factor the parse into
   `parse_remote_version(txt)` and test it directly; test `pkg_latest` by mocking `readLines`. Commit:
   `feat: add pkg_latest() to look up the newest version per source`.
2. **`sitrep(updates)` (M)** — `R/sitrep.R`, `tests/testthat/test-sitrep.R`. Tests: default output has no
   `latest`/`outdated` columns; `updates = TRUE` adds them; outdated true/false/NA cases (including
   `0.10.0` vs `0.9.0` numeric ordering); not-installed member has `NA`; report text shows `-> x available`,
   the Updates section, and `Could not check`; invalid `updates` errors. Commit:
   `feat: report newer available versions in sitrep(updates = TRUE)`.
3. **`updates` check (S)** — `R/checks.R`, `tests/testthat/test-checks.R`. Tests: pass / warn-outdated /
   warn-all-unknown; absent when `updates = FALSE`; check order. Commit:
   `feat: add an updates check to sitrep(checks = TRUE, updates = TRUE)`.
   CHECKPOINT A: `devtools::test()` all green; live run of `sitrep(updates = TRUE)` on this machine must
   flag medfit (0.7.0 -> 0.18.0) and must not flag RMediation (CRAN 1.6.1 is current). Those two
   outcomes are the positive and negative control; if either is wrong, stop and fix before continuing.
4. **`mediationverse_update()` args (M)** — `R/update.R`, `tests/testthat/test-update.R`. Tests: defaults
   unchanged (existing tests untouched and passing); `dry_run` prints and installs nothing (mock the
   installer to fail if called); `only_outdated` keeps outdated and not-installed members, drops current
   ones, keeps unknown; validation of package names still runs first. Commit:
   `feat: add only_outdated and dry_run to mediationverse_update()`.
5. **Docs and hygiene (S)** — roxygen, README, getting-started, NEWS, `.STATUS`. Gates:
   `devtools::test()` 0 failures; `bash scripts/check-local.sh` PASS; `pkgdown::check_pkgdown()` clean;
   coverage >= 90% total and 100% on `R/latest.R`; `git diff DESCRIPTION` empty. Commit:
   `chore: NEWS and docs for the 0.4.0 update checks`.
6. **Design document (S)** — section 1.6. Commit: `docs: design notes for mediate() and a pipeline object`.

CHECKPOINT B: re-run all gates on the committed tree; planted-defect check: make `numeric_version`
comparison use string comparison in `sitrep` (so `0.9.0` > `0.10.0`), confirm the ordering test fails,
revert, confirm green. Paste the live `sitrep(updates = TRUE)` and `mediationverse_update(dry_run = TRUE)`
output into the end-of-run report.

## 3. Autonomy rules

Defaults (take them, never ask):

| Fork | Default | Why |
|------|---------|-----|
| Offline or HTTP error during a live run | report `Could not check`, treat as `NA` | offline is not a failure |
| Latest has a dev suffix (`0.6.0.9000`) | compare as is with `numeric_version` | matches r-universe's real value |
| Installed is newer than latest | `outdated = FALSE` | locally built or ahead of the index |
| JSON shape differs from the regex | `NA` | never parse speculatively |
| New NOTE in `check-local.sh` | fix if caused by this work, else record | only ERROR/WARNING gate |
| Roxygen churns `DESCRIPTION` | restore the 8.1.0 pin | repo convention |
| Test fails on this branch and on `origin/dev` | leave, record as baseline | baseline rule |
| Wording of messages | use the strings in section 1 | decided above |

Stop only for: a gate still red after two attempts at the same cause; a needed change outside scope
(sibling repos, `DESCRIPTION` Imports, `.github/`); anything requiring a push, merge, tag, release or
branch switch. Commits are local; no amends; re-stage and re-commit if a markdown hook rewrites files.
Before each `git add`, read `git status`.

Non-actions until the user says so: `git push`, `gh pr create`, merge, tag, release, branch deletion,
touching `~/projects/r-packages/active/mediationverse` or sibling repos,
`feature/adhd-friendly-status-dashboard`.

## 4. Release sequence (listed, not executed without go-ahead)

Push branch and open PR to `dev` with the Checkpoint B transcript; wait for CI; ask before the squash
merge. Then release prep PR (`DESCRIPTION` 0.4.0, NEWS retitle, `.STATUS`); `dev` to `main` merge-commit PR;
verify CI on `main`; tag `v0.4.0` and GitHub release; check pkgdown and r-universe (lags); bump `dev` to
0.4.0.9000 via its own PR; delete merged branches by verified PR head SHA (the user runs `branch -D`).

## 5. Out of scope

`mv_options()` (no sibling reads a `mediationverse.*` option), `mediate()` / `mediation_pipeline()`
(design only), CRAN submission, the ADHD dashboard branch, adding `jsonlite` or any dependency.

## 6. Risks

| Risk | Impact | Mitigation |
|------|--------|-----------|
| r-universe or crandb changes its payload | Med | `NA` fallback, parse isolated and unit-tested |
| Network calls in an unexpected place | High | opt-in only (`updates = TRUE`), every test mocks `pkg_latest`, none at load time |
| "Latest" disagrees with what `update()` installs | Med | latest follows the registry `source` (section 0) |
| Slow lookups stall `sitrep()` | Low | 5 s timeout per request, six requests at most |
