# Plan: mediationverse 0.3.0 (self-contained, executable without questions)

Status: **released** as 0.3.0 (tag `v0.3.0` at c634ef0, PRs #34 to #36).

Date: 2026-11-17 | Branch `feature/release-0.3.0` off `dev` at 477908a (0.2.0.9000, includes sitrep
provenance, PR #33). Worktree: `/Users/davood/.worktree/mediationverse/restore-342f7b`.
Backlog source: `BRAINSTORM-tidyverse-functions-2026-06-19.md` (items 3, 4, 6, 8, 9, 10 unbuilt) and the
0.2.0 SPEC "Deferred" list. Distribution: GitHub + r-universe, not CRAN (CRAN is blocked on probmed,
medrobust, medsim and a medfit >= 0.5.0 on CRAN; tracked in `.STATUS`, unchanged here).

Theme: session ergonomics (news, attach everything, quiet startup) plus a small docs correction.

## 0. Evidence behind the scope

- No sibling package reads a `mediationverse.*` option (grep of `R/` in medfit, probmed, RMediation,
  medrobust, medsim, missingmed: 0 files). So `mv_options()` is out; only the option the meta-package
  itself reads (`mediationverse.quiet`) is added.
- `utils::news(package = p)` works for all six members on this machine. Columns: `Version, Date,
  Category, Text, HTML`; `Version` is `character`. Versions found: medfit 10, RMediation 12, probmed 6,
  missingmed 11, medsim 9, medrobust 9. Row-per-bullet is why 0.2.0 deferred this: `n` must count
  versions, not rows.
- `vignettes/roadmap.Rmd` is already a pointer page to the planning hub: no drift, no edit.
  Real docs drift found: `STATUS.md` badge table has no `missingmed` row (a core member since 0.1.1) and a
  2026-07-23 date; `.STATUS` needs the 0.3.0 line; README and `getting-started.qmd` do not mention the new
  functions.
- Out of scope, listed once so nobody re-opens them: `mv_options()` (no consumer), `mediation_pipeline()` /
  `mediate()` (needs a design pass against medfit's current API; 0.4.0 candidate), the ADHD dashboard branch
  `feature/adhd-friendly-status-dashboard` (keep as is), CRAN submission.

## 1. Decisions made up front (no "TBD")

### 1.1 `mediationverse_news()` — new file `R/news.R`

```r
mediationverse_news(n = 3L, include_self = FALSE)
```

- `n`: single whole number >= 1, else `cli::cli_abort("{.arg n} must be a single whole number >= 1.")`.
- Packages: `mv_core_packages()` (plus `mediationverse` when `include_self`), same convention as
  `mediationverse_citations()`.
- Internal mockable helper in the same file (the pattern of `pkg_citation()`):

  ```r
  # News for one package as a plain data.frame (Version, Date, Category, Text), or NULL when
  # it has no usable NEWS. Isolated so tests can mock it.
  pkg_news <- function(pkg) {
    res <- tryCatch(suppressWarnings(utils::news(package = pkg)), error = function(e) NULL)
    if (is.null(res) || NROW(res) == 0L) return(NULL)
    as.data.frame(res)[, c("Version", "Date", "Category", "Text"), drop = FALSE]
  }
  ```

- Version selection (pure internal helper `select_news_versions(df, n)`): parse
  `numeric_version(df$Version, strict = FALSE)`, drop rows where parsing gives `NA` (e.g. "development
  version" headers), take the `n` highest distinct versions, return rows for those versions ordered newest
  version first, original bullet order within a version.
- Walk members: `pkg_state(pkg)` is `"absent"` -> `not_installed`; `"broken"` -> `broken`; `"ok"` -> call
  `pkg_news()`; `NULL` or zero selected rows -> `no_news`.
- Return (invisibly) a long data frame with columns `package, version, date, category, text`
  (character; `category`/`date` are `NA_character_` when missing), class
  `c("mediationverse_news", "data.frame")`, attributes `not_installed`, `broken`, `no_news`, `n`.
  `mediationverse_news()` prints it (like `citations()`), then returns invisibly.
- `print.mediationverse_news`: `cli::cli_h1("mediationverse news")`; per package `cli::cli_h2("{pkg}")`;
  per version a bold line `{version}` plus ` ({date})` when a date exists; bullets as `* text` (collapse
  whitespace to one line, cap each bullet at 200 characters with an ellipsis). Trailing notes, only when
  non-empty: `No NEWS available for: {.pkg ...}`, `Not installed: ...`, `Installed but cannot be loaded: ...`.
- S3 registration through roxygen `@export` on the print method (NAMESPACE gains `S3method(print,
  mediationverse_news)` and `export(mediationverse_news)`).

### 1.2 `mediationverse_attach_all()` — new file `R/attach-all.R`

```r
mediationverse_attach_all()
```

- No arguments. Iterates `mv_core_packages()`.
- Mockable helper `pkg_attach(pkg)`: `suppressPackageStartupMessages(library(pkg, character.only = TRUE,
  warn.conflicts = FALSE))` (variable + `character.only` is the repo's established pattern that avoids the
  R CMD check `library()` note). Returns invisibly.
- Per package, status strings exactly: `"attached"`, `"already attached"` (`is_attached(pkg)`), `"not
  installed"` (`pkg_state` is `"absent"`), `"failed to load"` (`pkg_state` is `"broken"`, or `pkg_attach`
  raised an error; never abort the loop).
- Returns invisibly a named character vector (names = packages, values = statuses). Prints with cli:
  `cli::cli_alert_success("Attached {.pkg {pkgs}}")` for newly attached, `cli_alert_info` for already
  attached, `cli_alert_warning` for the other two (each line only when its group is non-empty). When 2+
  packages are attached or already attached, end with `cli::cli_alert_info("Check for masked functions
  with {.run mediationverse_conflicts()}.")`.
- `library(mediationverse)` selective loading is not touched.

### 1.3 `mediationverse.quiet` — edit `R/zzz.R`, `R/mediationverse-package.R`

- New internal helper (in `R/zzz.R`): `mv_quiet <- function() isTRUE(getOption("mediationverse.quiet", FALSE))`.
- `.onAttach`: keep attaching medfit exactly as today. If `mv_quiet()` is `TRUE`, return right after the
  attach attempt and emit nothing. The "medfit could not be loaded" message is a failure notice and is
  always shown, even when quiet.
- Document the option in `R/mediationverse-package.R` under `@section Options:` (one bullet:
  `mediationverse.quiet`, logical, default `FALSE`: suppress the attach banner). README gets the
  `.Rprofile` snippet `options(mediationverse.quiet = TRUE)`.

### 1.4 Docs

- `STATUS.md`: add the `missingmed` row (same badge pattern as the other rows, `data-wise/missingmed`,
  lifecycle and repo-status badges copied from medsim's row because that file has no per-package
  lifecycle for missingmed; do not invent a stable status), add `missingmed` to the "Package Websites",
  "GitHub Actions" and "Code Coverage" lists if those lists use all six names, and set `Last Updated` to
  2026-11-17 with a one-clause reason. Skip a row's cells only if the pattern cannot be copied verbatim.
- `README.md`: add a short "Session helpers" block under Usage with `mediationverse_news()`,
  `mediationverse_attach_all()` and the quiet option; leave "From CRAN (future)" as is (it is accurate).
- `vignettes/getting-started.qmd`: one short subsection listing the same three (not rendered by
  `check-local.sh`; keep edits plain markdown).
- `.STATUS`: set `last_updated: 2026-11-17`, extend `done:` with one clause for 0.3.0 work in progress,
  leave `next:` (CRAN block) untouched.
- `vignettes/roadmap.Rmd`: no change (already current).

### 1.5 Release hygiene

- `NEWS.md`: under `# mediationverse (development version)` > `## New features`, three bullets (news,
  attach_all, quiet option), no literal member version numbers.
- `_pkgdown.yml`: add `mediationverse_news` and `mediationverse_attach_all` to the "Package Management"
  reference contents. Verify with `pkgdown::check_pkgdown()`.
- Roxygen is pinned at 8.1.0 and 8.1.1 is installed: after every `devtools::document()` restore
  `Config/roxygen2/version: 8.1.0` in `DESCRIPTION` (`git diff DESCRIPTION` must be empty at commit time).
- `DESCRIPTION` stays `0.2.0.9000` throughout implementation. The version bump to 0.3.0 happens only in the
  release step (section 4).
- US English in everything written.

## 2. Tasks (run in this order; each ends with its own commit)

Conventions for every task: tests first (write, watch them fail, then implement); match the existing
style (testthat 3, `local_mocked_bindings`, content assertions, no snapshots, helper functions named
`mock_*` / `run_*` like `test-citations.R`); package code uses `pkg::fun()` and never `library()`.
Commit trailer on every commit: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

### Task 1 — `mediationverse_news()` (M)

Files: `R/news.R`, `tests/testthat/test-news.R`, `NAMESPACE` and `man/mediationverse_news.Rd`
(generated).
Tests (names verbatim): `news() returns a classed long data frame`; `news() keeps the n newest versions
per package, newest first`; `news() orders versions numerically (0.10.0 above 0.9.0)`;
`news() drops unparseable version headers`; `news() reports packages with no NEWS`; `news() reports
absent and broken members`; `news() validates n` (0, -1, 1.5, "a", c(1,2), NA each error);
`news() include_self adds mediationverse`; `news() prints version headings and bullets`;
`select_news_versions() ignores rows with NA version`.
Acceptance: all tests pass; `mediationverse_news(n = 1)` on this machine prints one version per installed
member and RMediation (a GitHub install, positive control) appears.
Verify: `Rscript -e 'devtools::test(filter = "news")'`, then
`Rscript -e 'devtools::load_all(); mediationverse_news(n = 1)'`.
Commit: `feat: add mediationverse_news()`.

### Task 2 — `mediationverse_attach_all()` (S)

Files: `R/attach-all.R`, `tests/testthat/test-attach-all.R`, `NAMESPACE`, `man/` (generated).
Tests: `attach_all() attaches installed members and reports statuses`; `attach_all() skips already attached
members`; `attach_all() reports absent members`; `attach_all() survives a member that fails to load`
(mock `pkg_state` to `"broken"` for one and `pkg_attach` to error for another; the call still returns);
`attach_all() returns a named character vector invisibly`; `attach_all() suggests conflicts when 2+ are
attached`. Tests must never attach real members: every test mocks `pkg_attach`, `pkg_state` and
`is_attached`.
Acceptance: tests pass; a live run on this machine ends with the six members attached or reported.
Verify: `Rscript -e 'devtools::test(filter = "attach-all")'`, then in a fresh process
`Rscript -e 'devtools::load_all(); print(mediationverse_attach_all()); print(search())'`.
Commit: `feat: add mediationverse_attach_all()`.

### Task 3 — `mediationverse.quiet` (S)

Files: `R/zzz.R`, `R/mediationverse-package.R`, `tests/testthat/test-startup.R`, `man/` (generated).
Tests: `mv_quiet() is FALSE by default and TRUE only for TRUE`; `.onAttach() prints the banner by default`
(mock `mediationverse_attach`, capture `packageStartupMessage`); `.onAttach() is silent when quiet`;
`.onAttach() still reports a medfit load failure when quiet` (mock `mediationverse_attach` to error).
Use `testthat::local_options(mediationverse.quiet = TRUE)`.
Acceptance: tests pass; `Rscript -e 'options(mediationverse.quiet = TRUE); library(mediationverse)'` prints
nothing; without the option the banner appears.
Verify: both commands above, run from the worktree with `devtools::load_all()` replaced by an installed
build only if `load_all` does not trigger `.onAttach`; otherwise rely on the unit tests plus a
`pkgload::load_all(".", attach = TRUE)` run.
Commit: `feat: add the mediationverse.quiet option`.

CHECKPOINT A (after tasks 1-3): `Rscript -e 'devtools::test()'` shows 0 failures and more than the current
339 expectations; if a pre-existing test fails, reproduce it on `dev` before touching it: read the failing assertion,
then run that test file against `origin/dev` in a throwaway `git worktree add --detach` under the scratchpad
directory (remove it afterward). Never use `git stash` here.

### Task 4 — Docs correction (M)

Files: `STATUS.md`, `README.md`, `vignettes/getting-started.qmd`, `.STATUS`.
Steps: apply section 1.4 exactly. Before editing each file run `git log -1 --format=%cs -- <file>` and edit
only real gaps (the repo rule on documentation currency). Grep the docs for the strings `mediationverse_citations`
and `sitrep` to place the new mentions beside the existing ones.
Acceptance: `grep -c missingmed STATUS.md` is greater than 0; README shows the three new items;
`git diff --stat` touches only the four files.
Verify: `grep -n "missingmed" STATUS.md | head`, `git diff --stat`.
Commit: `docs: add missingmed to STATUS.md and document the new session helpers`.

### Task 5 — Hygiene and gates (S)

Files: `NEWS.md`, `_pkgdown.yml`, generated `man/`.
Steps, in order: `Rscript -e 'devtools::document()'`, restore the roxygen pin in `DESCRIPTION`, add the NEWS
bullets, add the pkgdown reference entries.
Gates (all must pass):
1. `Rscript -e 'devtools::test()'`: 0 failures, 0 unexpected skips.
2. `bash scripts/check-local.sh`: PASS (the `.git` hidden-entry NOTE is the known worktree artifact).
3. `Rscript -e 'pkgdown::check_pkgdown()'`: no problems.
4. `Rscript -e 'covr::package_coverage()'`: total >= 80% and each new file >= 90%.
5. `git diff DESCRIPTION`: empty.
Commit: `chore: NEWS, docs index and roxygen for 0.3.0 features`.

CHECKPOINT B (final): re-run gates 1-5 once more on the committed tree, then a live run of
`mediationverse_news(n = 1)`, `mediationverse_attach_all()` and the quiet option, and paste each output
into the end-of-run report. A planted-defect check proves the news tests can fail: temporarily make
`select_news_versions()` sort ascending, confirm the ordering test fails, revert, and confirm green.

## 3. Autonomy rules (what "no questions" means here)

Defaults for foreseeable forks (take the default; never ask):

| Fork | Default | Why |
|------|---------|-----|
| NEWS header is not a parseable version | drop it | cannot be ordered; documented in 1.1 |
| A member has NEWS but the chosen versions give zero rows | list under "No NEWS available" | same outcome for the user |
| `utils::news()` warns | suppress, never fail | members may ship odd NEWS files |
| `check-local.sh` shows a new NOTE | investigate, fix if caused by this work, else record in the report | only ERROR/WARNING gate |
| Roxygen churns `DESCRIPTION` | restore the 8.1.0 pin | repo convention |
| Test fails on both this branch and `dev` | leave it, record it as baseline in the report | baseline rule |
| Wording choices in messages | follow the strings in section 1 | decided above |

Stop conditions (the only reasons to stop and report): a gate still red after two fix attempts for the same
cause; a change that would need an out-of-scope file (sibling repos, `DESCRIPTION` Imports, `.github/`);
anything that would require a push, merge, tag, release, branch switch or deletion.

Commit plan: five local conventional commits as listed, no amends, pre-commit hooks that auto-fix
markdown mean re-stage and make a new commit. Before each `git add`, run `git status` and read any file
whose name or diff looks like config/auth (the pre-stage secret-scan rule); none is expected.

Explicit non-actions until the user says so: `git push`, `gh pr create`, merging, tagging, releasing,
branch deletion, switching branches, touching `~/projects/r-packages/active/mediationverse`, sibling
repos or `feature/adhd-friendly-status-dashboard`. A hook note claiming this branch is "86 days old" is
wrong (created 2026-11-17); ignore it.

## 4. Release sequence (listed, NOT executed without the user's go-ahead)

1. Push `feature/release-0.3.0`, open a PR to `dev` whose body quotes the Checkpoint B transcript (exact
   commands, pass counts, live-run output) per the E2E-before-PR rule; wait for CI; ask before squash-merge.
2. Final commit on the branch (or a release-prep commit): `DESCRIPTION` 0.3.0, retitle the NEWS heading to
   `# mediationverse 0.3.0` with a one-paragraph summary, update `.STATUS` version lines; grep the repo
   for `0.2.0.9000`.
3. `dev` to `main` release PR (`Release: v0.3.0`), merge commit, verify CI green, tag `v0.3.0`, GitHub
   release, confirm pkgdown root and r-universe serve 0.3.0 (r-universe lags; re-check, do not block).
4. Bump `dev` to `0.3.0.9000` through its own PR; delete the merged feature branch with the
   verified-by-PR-head-SHA method.

## 5. End-of-run report (the single message at the end of implementation)

State: commits made (hashes), final gate output with counts, live-run outputs, anything found and left
alone, and the one question that remains: whether to push and open the PR (section 4, step 1).

## 6. Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| NEWS formats differ (`NEWS.md` vs `NEWS.Rd`) | Med | go through `utils::news()`; mocked tests for odd shapes; live run over all six |
| `attach_all()` masks functions across members | Med | final hint to run `mediationverse_conflicts()` |
| Quiet option silences a real failure | Low | failure notice is always shown (1.3), with a test |
| Scope creep into pipeline/mediate/mv_options | High | listed out of scope with reasons (section 0) |
| `STATUS.md` badge copy-paste errors | Low | copy the medsim row verbatim and replace the name only |
