# Adversarial Review: shiny-apps BRAINSTORM/GRILL

**Date**: 2026-08-03
**Target**: [BRAINSTORM-shiny-apps-location-2026-08-03.md](BRAINSTORM-shiny-apps-location-2026-08-03.md), [GRILL-shiny-apps-location-2026-08-03.md](GRILL-shiny-apps-location-2026-08-03.md)
**Grounding**: `notebooklm` "R Package Development" notebook (294 sources, freshly
enriched with 5 Posit Connect Cloud / golem / rsconnect sources added this
session) + direct web research.
**Lenses**: code-review, frontend, backend

## Verdict

Core recommendation (monorepo, standalone deploy, skip shinyapps.io) is
independently confirmed by the notebook corpus — it explicitly names this
"Decoupled Monorepo" pattern and recommends it for exactly this scenario
("a centralized computational R package that powers a suite of different
dashboards"). No reversal. Six findings below, most fixed directly (doc
accuracy), two left as open decisions for you.

## Findings

### 1. [FIXED] `DESCRIPTION or renv.lock` conflates two different things

**File**: BRAINSTORM, line 59 (structure diagram)
**Problem**: Listed as interchangeable alternatives ("`DESCRIPTION or
renv.lock` — per-app dependency pin"). They aren't alternatives —
`renv.lock` pins dependencies for a plain `app.R`; `DESCRIPTION` only
applies once an app escalates to a golem package (which also still needs
its own `renv.lock`). Presenting them as an "or" choice would mislead
whoever scaffolds the first app into picking one arbitrarily.
**Fix applied**: split into `renv.lock` (always) and a conditional golem
`DESCRIPTION` line tied to the existing escalation trigger.

### 2. [FIXED] Imports/Suggests cross-reference is a category error

**File**: BRAINSTORM, lines 69–73
**Problem**: Doc says per-app dependency isolation "mirrors the
`Imports`/`Suggests` isolation you already use in `mediationverse`." That's
wrong — Imports/Suggests governs which dependencies a *package* pulls in at
install time. A plain `app.R` isn't a package and has no Imports/Suggests;
its isolation comes purely from each app subdirectory having its own
`renv.lock`. The two mechanisms solve different problems and citing one as
justification for the other is a documentation-correctness bug, not just a
stylistic gap.
**Fix applied**: replaced the analogy with the correct mechanism
(per-app `renv.lock`), and moved the real Imports/Suggests parallel to
where it actually applies — the golem-escalation case, where a promoted app
*is* a package and the existing convention genuinely transfers.

### 3. [FIXED] Missing `Config/Needs/deploy` for CI-only deploy tooling

**File**: BRAINSTORM, escalation-trigger paragraph (lines 75–83)
**Problem**: Once an app escalates to a golem package, `rsconnect` (the
deploy tool) must NOT go in that package's `Imports` or `Suggests` — it's a
CI-time-only dependency. The R ecosystem convention (used by
`r-lib/actions/setup-r-dependencies`) is a `Config/Needs/deploy:` field in
`DESCRIPTION`. The escalation-trigger text didn't mention this, so a future
golem-ified app would likely misdeclare `rsconnect` as `Suggests`,
polluting the package's public dependency surface for a tool end users
never need.
**Fix applied**: added `Config/Needs/deploy: rsconnect` to the escalation
note.

### 4. [FIXED] Test-plan names no Shiny-specific testing tool

**File**: BRAINSTORM, Test-Plan Scaffolding section (lines 109–122)
**Problem** (frontend lens): `e2e` and `dogfood` are generic labels. The R
Shiny ecosystem has a dedicated tool for this — `shinytest2` (snapshot +
interaction testing) and `testServer()` (server-logic unit tests without a
browser). Leaving the tier unnamed means whoever implements the first app's
tests has to research this from scratch instead of following a stated
convention.
**Fix applied**: named `shinytest2` in the `e2e` stub.

### 5. [FIXED] CI blueprint omits the actual Posit-required deploy artifact

**File**: BRAINSTORM, structure diagram (`deploy.yml` line 63) and GRILL
decision #6 (path-filtered CI)
**Problem** (backend lens): Neither doc mentions that Posit Connect
requires a `manifest.json` (generated via `rsconnect::writeManifest()`) as
the actual environment blueprint the server uses to reconstruct package
versions — `renv.lock` alone isn't sufficient for Connect deploys. The
GRILL doc's CI decision (path-filtered, per-repo secret) is right but
incomplete without this step; omitting it would produce a CI workflow that
looks complete but fails at `rsconnect::deployApp()` time.
**Fix applied**: added a `manifest.json` generation step note to the
structure/CI description in BRAINSTORM.

### 6. [OPEN — not fixed, needs your call] No stated secrets-in-app-code rule

**File**: GRILL, decision #5 (deploy secrets)
**Problem** (backend/security lens): GRILL locked "per-repo GitHub Actions
secret" for the *deploy credential* — correct, and confirmed by the
corpus. But neither doc states the companion rule for secrets an app might
need *at runtime* (a DB connection string, an API key baked into an app's
own config) — `Sys.getenv()` inside app code, never hardcoded, and for
static encrypted config files the `secret` R package's RSA-vault pattern.
This doesn't block the structure decision (no app needs runtime secrets
yet, since apps are visualization-only per current scope), but it's a real
gap if a future app connects to a live data source.
**Recommendation**: add "no hardcoded credentials in app code;
`Sys.getenv()` only" as a stated rule in the future `shiny-apps/CLAUDE.md`
(already flagged as a doc-impact item) rather than leaving it implicit.
Not applying a fix now — this is a policy statement for a repo that
doesn't exist yet, better decided when you scaffold it.

## Not Flagged (checked, found solid)

- **Frontend / shared theming across apps** — considered, but with only
  "few shared apps" and no app built yet, a shared theme package is
  premature; the golem-escalation trigger already covers "when an app
  needs shared logic," and theming can piggyback on that same threshold
  rather than needing its own rule now.
- **Accessibility (WCAG)** — considered; deferred for the same reason as
  above — no app exists to audit yet, and it's a per-app concern at build
  time, not a repo-structure concern.

## Corpus Update

Added 5 sources to the "R Package Development" NotebookLM notebook
(`ad03f0dc-9936-474b-9e28-435faa2a89fd`) this session:
Connect Cloud Shiny-R deploy guide, Connect Cloud GitHub publishing guide,
Posit Solutions GitHub Actions CI/CD guide, golem chapter (Engineering
Production-Grade Shiny Apps), rsconnect package docs. Notebook now grounds
future shiny/deploy questions for this ecosystem, not just general R
package-dev fundamentals.
