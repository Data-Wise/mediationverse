# mediationverse — Fix & Improvement Spec

This spec addresses all issues identified in the project review.
Work through each task in order; earlier tasks unblock later ones.

---

## Task 1 — Fix function name inconsistency between site and README (CRITICAL)

**Problem:** The pkgdown site (`index.Rmd` / `README.md` rendered by pkgdown)
uses `pmed(med_data)` and `bound_ne(...)`, while the GitHub `README.md` uses
`compute_pmed(med_data)` and `sensitivity_analysis(med_data)`. Exactly one of
these is the real exported function name.

**Steps:**
1. Open `R/packages.R`, `NAMESPACE`, and the `probmed` and `medrobust` package
   NAMESPACE files (or their GitHub pages) to confirm the canonical exported
   function names.
2. Open `README.md` (root) and find every Quick Start / workflow code block.
3. Open `vignettes/getting-started.qmd` and `vignettes/mediationverse-workflow.qmd`.
4. Standardize every code example to use the confirmed function names.
5. Run `devtools::build_readme()` to rebuild the rendered README and confirm
   no errors.

**Acceptance:** `grep -r "compute_pmed\|sensitivity_analysis\|pmed(\|bound_ne" README.md vignettes/`
shows only one consistent name in use.

---

## Task 2 — Fix NEWS.md format for pkgdown compatibility

**Problem:** `NEWS.md` uses non-standard top-level headers with inline dates
(e.g., `## Bug Fixes (2026-06-19)`) instead of the required pkgdown format.
pkgdown requires `# packagename X.Y.Z` as the top-level anchor per release.

**Steps:**
1. Open `NEWS.md`.
2. Restructure into standard format:
   ```
   # mediationverse (development version)

   ## Bug Fixes
   * ...

   # mediationverse 0.1.0 (2025-12-15)

   ## Breaking Changes
   * ...

   ## Bug Fixes
   * ...
   ```
3. Move the `(2026-06-19)` and `(2025-12-15)` inline dates to their proper
   release header positions.
4. Ensure each bullet starts with `*` (not `-`), per R convention.
5. Run `pkgdown::build_news()` and confirm it renders correctly at `news/index.html`.

**Acceptance:** `pkgdown::build_news()` completes without warnings; the
rendered page shows two distinct version sections.

---

## Task 3 — Fix medrobust missing Build badge

**Problem:** The Package Overview table in `README.md` shows `—` (em dash)
for the `medrobust` Build column. This signals no CI is configured.

**Steps:**
1. Check whether `medrobust` has a GitHub Actions R-CMD-check workflow at
   `https://github.com/Data-Wise/medrobust/blob/main/.github/workflows/`.
2. If no workflow exists, note that the badge cannot be added until CI is
   set up in the medrobust repo (out of scope here — open a GitHub Issue
   on `Data-Wise/medrobust` requesting it).
3. If a workflow exists, find the correct badge URL pattern:
   `[![R-CMD-check](https://github.com/Data-Wise/medrobust/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Data-Wise/medrobust/actions/workflows/R-CMD-check.yaml)`
4. Replace the `—` in the table with the correct badge markdown.

**Acceptance:** The `medrobust` row in `README.md` has a real badge (or a
filed issue link if CI isn't set up upstream).

---

## Task 4 — Investigate and document the medfit R-CMD-check failure

**Problem:** The Package Overview table shows `medfit` with a red `failing`
R-CMD-check badge, even though `medfit` is the foundation package and is on CRAN.

**Steps:**
1. Navigate to `https://github.com/Data-Wise/medfit/actions` and find the
   most recent failing R-CMD-check run.
2. Read the error output and identify the root cause.
3. If the fix is in `mediationverse` (e.g., a wrong version constraint in
   `DESCRIPTION`): apply the fix directly.
4. If the fix requires a change in the `medfit` repo: open a GitHub Issue
   on `Data-Wise/medfit` with the exact error message and a proposed fix.
5. Update `STATUS.md` (root) with a note on the current status and ticket link.

**Acceptance:** Either the badge turns green, or a tracking issue exists with
a clear description of the failure.

---

## Task 5 — Fix `_pkgdown.yml` RMediation URL casing

**Problem:** The navbar Ecosystem menu links to
`https://Data-Wise.github.io/rmediation/` (lowercase `r`) but the package
is `RMediation`. GitHub Pages on Linux is case-sensitive.

**Steps:**
1. Open `_pkgdown.yml`.
2. Find all references to `rmediation` in href values.
3. Change them to `RMediation` (verify the actual GitHub Pages URL first by
   visiting `https://Data-Wise.github.io/RMediation/` in a browser).
4. If the correct URL uses lowercase, leave it and add a comment noting
   the intentional casing.

**Acceptance:** The RMediation link in the deployed site resolves to a
live pkgdown site, not a 404.

---

## Task 6 — Fix pkgdown logo size

**Problem:** `_pkgdown.yml` sets `logo: width: 350px`, which overflows on
narrow viewports and is much larger than the pkgdown default (~120px).

**Steps:**
1. Open `_pkgdown.yml`.
2. Change:
   ```yaml
   logo:
     image: man/figures/logo.png
     align: right
     width: 350px
   ```
   to:
   ```yaml
   logo:
     image: man/figures/logo.png
     align: right
   ```
   (Remove the `width` override to use the pkgdown default, which is
   responsive.)
3. Run `pkgdown::build_home()` and screenshot the result at both 1280px
   and 768px viewport widths.

**Acceptance:** Logo is visible and does not overflow the header at either
viewport width.

---

## Task 7 — Remove duplicate sidebar links

**Problem:** The pkgdown sidebar has both "Browse source code" (auto-generated
by pkgdown from `URL:` in `DESCRIPTION`) and a manually added "Source Code"
link — both pointing to the same GitHub repo URL.

**Steps:**
1. Open `_pkgdown.yml`.
2. In the `home.sidebar.links` list, remove the `Source Code` entry (keep
   "r-universe (binaries)", "Report Issues", and "Request Feature").
3. The "Browse source code" link is auto-generated from `DESCRIPTION URL:`
   and will remain.
4. Run `pkgdown::build_home()` and confirm the sidebar has no duplicates.

**Acceptance:** The right sidebar has exactly one GitHub repository link.

---

## Task 8 — Add `mediationverse_sitrep()` to the Quick Start

**Problem:** `mediationverse_sitrep()` is the most useful diagnostic function
for new users but is not mentioned in the homepage Quick Start or the
Getting Started vignette.

**Steps:**
1. Open `README.md`. After the Quick Start code block, add a "Verify your
   installation" subsection:
   ```r
   # Check what's installed and available
   mediationverse_sitrep()
   ```
   With a one-sentence description: "Prints a situation report of all
   ecosystem packages, their versions, and installation sources."
2. Open `vignettes/getting-started.qmd` and add the same code block near
   the top, after the `library(mediationverse)` call.
3. Run `devtools::build_readme()` and `pkgdown::build_articles()` to confirm
   rendering.

**Acceptance:** `mediationverse_sitrep()` appears in both the README Quick
Start and the Getting Started vignette.

---

## Task 9 — Replace dead-end "Development Progress" links with inline summary

**Problem:** The "Development Progress" section on the homepage links to a
separate planning repo (`Data-Wise/mediation-planning`) that may be private
or inaccessible to external users. It provides no useful information in place.

**Steps:**
1. Open `README.md` and find the "Development Progress" section.
2. Replace it with a compact inline table:
   ```markdown
   ## Development Status

   | Package     | Status      | Next Milestone                        |
   |-------------|-------------|---------------------------------------|
   | medfit      | Stable/CRAN | Phase 5 — serial mediation            |
   | probmed     | Stable      | CRAN submission                       |
   | RMediation  | Stable/CRAN | Maintenance only                      |
   | medrobust   | Experimental| Complete partial ID bounds            |
   | medsim      | Experimental| HPC integration                       |
   ```
3. Keep links to the Master Roadmap and PROJECT-HUB only if those pages
   are publicly accessible. If not, remove them.

**Acceptance:** A first-time visitor can understand the ecosystem's
maturity at a glance without following external links.

---

## Task 10 — Improve `attach.R` readability

**Problem:** `mediationverse_attach()` uses a variable `foundation <- "medfit"`
and then `library(foundation, character.only = TRUE)`, which is unnecessarily
indirect.

**Steps:**
1. Open `R/attach.R`.
2. Replace:
   ```r
   foundation <- "medfit"
   if (!is_attached(foundation)) {
     suppressPackageStartupMessages(
       library(foundation, character.only = TRUE, warn.conflicts = FALSE)
     )
   }
   ```
   with:
   ```r
   if (!is_attached("medfit")) {
     suppressPackageStartupMessages(
       library("medfit", character.only = TRUE, warn.conflicts = FALSE)
     )
   }
   ```
3. Run `R CMD check` locally and confirm no new warnings.

**Acceptance:** `R/attach.R` contains no intermediate string variable for
the package name; the logic is unchanged.

---

## Task 11 — Clarify installation expectations for non-CRAN packages

**Problem:** The homepage implies `pak::pak("Data-Wise/mediationverse")`
installs everything, but `probmed`, `medrobust`, and `medsim` are in
`Suggests` (not `Imports`), so they are not auto-installed with the
meta-package.

**Steps:**
1. Open `README.md`, find the Installation section.
2. After the r-universe install block, add an explicit note:
   ```markdown
   > **Note:** `probmed`, `medrobust`, and `medsim` are not on CRAN yet.
   > Install them individually as needed:
   > ```r
   > pak::pak(c("Data-Wise/probmed", "Data-Wise/medrobust", "Data-Wise/medsim"))
   > ```
   ```
3. In `vignettes/getting-started.qmd`, add the same note before the first
   `library(probmed)` call.

**Acceptance:** A user who only runs `install.packages("mediationverse")`
will see clear guidance explaining why `library(probmed)` might fail.

---

## Task 12 — Cut a v0.1.0 release

**Problem:** The repo has 0 published releases and has been at `0.0.0.9000`
throughout significant breaking changes (selective loading, CRAN submission
of medfit). Users have no stable version to pin.

**Steps:**
1. Ensure Tasks 1–11 above are complete and all checks pass.
2. Update `DESCRIPTION`: change `Version: 0.0.0.9000` to `Version: 0.1.0`.
3. Update `NEWS.md` top section from `# mediationverse (development version)`
   to `# mediationverse 0.1.0`.
4. Run `devtools::check()` — must be clean (0 errors, 0 warnings, ≤1 note
   for the Imports/namespace meta-package pattern).
5. Run `pkgdown::build_site()` — must complete without errors.
6. Commit with message `chore(release): bump to v0.1.0`.
7. On GitHub, create a new Release:
   - Tag: `v0.1.0`
   - Title: `mediationverse v0.1.0 — Selective loading & medfit CRAN integration`
   - Body: paste the `# mediationverse 0.1.0` section from `NEWS.md`.

**Acceptance:** `https://github.com/Data-Wise/mediationverse/releases` shows
a `v0.1.0` release; the version badge on the pkgdown site shows `0.1.0`.

---

## Verification Checklist

Run these after all tasks are complete:

```r
# In R, from the repo root:
devtools::check()          # 0 errors, 0 warnings
pkgdown::build_site()      # Completes cleanly
devtools::build_readme()   # No errors
testthat::test_local()     # All tests pass
```

```bash
# In the shell, from repo root:
grep -r "compute_pmed\|sensitivity_analysis" README.md vignettes/
# Should return 0 results if Task 1 standardized to pmed/bound_ne,
# or vice versa.
```
