# GRILL: Shiny Apps Location & Posit Connect Cloud Migration

**Date**: 2026-08-03 **Target**:
[BRAINSTORM-shiny-apps-location-2026-08-03.md](https://Data-Wise.github.io/mediationverse/BRAINSTORM-shiny-apps-location-2026-08-03.md)
**Recommendation grilled**: monorepo for shiny apps, separate from every
package repo, standalone deploy to Connect Cloud, skip shinyapps.io
entirely.

## Verdict

Recommendation **holds**, with one addition (escalation trigger) and two
explicit deferrals (repo creation itself; auth/naming details) called
out below as execution steps, not design gaps.

## Decision Ledger

| \# | Branch | Decision |
|----|----|----|
| 1 | Riskiest assumption — is Connect Cloud open for net-new app deploys today, independent of the shinyapps.io migration tool? | Confirmed yes — build directly on Connect Cloud, no interim shinyapps.io step. Original recommendation holds unmodified. |
| 2 | Workflow discipline — which branch pattern (multi-branch vs single-integration) for the new repo? | Single-integration: `main ← feature/*`. Matches every other r-packages repo except craft/missingmed; no `dev` branch to maintain. |
| 3 | Assumption reversal — does the monorepo structure survive if “few shared apps” turns out wrong (5+ apps, some tightly package-coupled)? | Researched (golem framework convention): still holds by default. An app that outgrows a simple `app.R` and needs its own tests/exports/versioning promotes to a dedicated golem-style package that `Imports` the target mediationverse package — it does NOT get embedded inside that package’s `inst/`. Explicit escalation trigger, not a vague future concern. |
| 4 | Blast radius — does repo creation (gh repo create, branch protection, initial scaffold) happen in this session? | No — separate, explicitly-authorized step per the no-cross-repo-work-without-permission rule. This grill session is a decision record only. |
| 5 | Deploy secrets — how is the Connect Cloud API token/credential managed in CI? | Per-repo GitHub Actions secret (e.g. `CONNECT_CLOUD_TOKEN`), scoped to `shiny-apps` only. Not an org-level shared secret — keeps blast radius of a leak/rotation to this one repo. |
| 6 | Deploy granularity — deploy only the changed app subdir, or redeploy every app on any push? | Path-filtered deploy (e.g. `dorny/paths-filter` or a changed-files diff step) — deploy only the app(s) whose subdirectory changed. More CI setup up front; avoids wasteful full-redeploys once the repo holds 3+ apps. |

## Open Questions (carried from brainstorm, still not blocking)

- Which package’s app to prototype first — pick 1 before assuming the
  pattern generalizes to all 5.
- Exact repo name / GitHub org placement (assumed `Data-Wise/shiny-apps`
  or similar, matching existing repo casing convention — not yet
  confirmed).
- Auth/access model on Connect Cloud (public vs. gated) — check once app
  count and audience are known.

## Structural Update to Brainstorm Doc

Add to `BRAINSTORM-shiny-apps-location-2026-08-03.md`, under “Proposed
structure”:

> **Escalation trigger**: an app promotes from a plain
> `apps/<name>/app.R` to its own golem-structured package (still living
> in the `shiny-apps` repo, or spun out to its own repo if it needs
> independent CRAN-style release tooling) once it needs its own test
> suite, versioned exports, or shared logic beyond a single `app.R`
> file. Until then, a bare `app.R` + per-app lockfile is sufficient —
> don’t pre-build package scaffolding for apps that don’t need it.

## Handoff

Next: `/craft:plan GRILL-shiny-apps-location-2026-08-03.md` once you’re
ready to scaffold the repo — or capture the escalation-trigger addition
into the BRAINSTORM doc first and revisit when the first app is chosen.
