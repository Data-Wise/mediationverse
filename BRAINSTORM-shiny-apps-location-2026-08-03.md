# BRAINSTORM: Shiny Apps Location & Posit Connect Cloud Migration

**Date**: 2026-08-03 **Depth**: default \| **Focus**: architecture

## Context

- Posit is retiring shinyapps.io in favor of Connect Cloud. Self-serve
  migration tool arrives September 2026; automatic migration waves start
  2027-01-28 (free), 2027-03-31 (Starter/Basic), 2027-06-30
  (Standard/Professional). Paid plans keep current pricing/seats
  through 2029. Nothing breaks today — this is a “decide the target
  structure before you migrate” window, not a fire drill.
- No shiny apps exist yet anywhere in the mediationverse ecosystem
  (`medfit`, `probmed`, `RMediation`, `medrobust`, `medsim`) — confirmed
  via repo scan. This is a greenfield structural decision, not a
  refactor of live apps.
- Answers so far: **few shared/cross-package apps** (not
  one-per-package), **standalone deploy** (not shipped inside package
  `inst/`, not launched via a package function).

## Recommendation

**Monorepo for shiny apps — separate from every package repo.**
Reasoning:

1.  **Coupling doesn’t justify co-location.** A shiny app embedded in a
    package repo (e.g. `inst/shiny-examples/` inside `medfit`) forces
    the app’s release cadence onto the package’s — a copy-tweak to the
    app triggers a package version bump, R CMD check, and (per this
    repo’s workflow) the full CRAN-release pipeline. You already ruled
    this out by picking “standalone only.”
2.  **Cross-package apps have no single home.** If an app visualizes
    output from `medfit` + `probmed` + `RMediation` together, it doesn’t
    belong inside any one of them — a monorepo sidesteps “which package
    owns it” entirely.
3.  **Deploy pipeline is simpler as one thing.** Connect Cloud (like
    shinyapps.io) deploys per-app-directory. A `shiny-apps/` monorepo
    with `apps/<app-name>/app.R` per subdirectory lets you
    `rsconnect::deployApp()` (or Connect Cloud’s equivalent) per
    subfolder without touching package release tooling at all — one
    repo, one CI workflow, N deploy targets.
4.  **This matches your existing precedent.** `mediationverse` itself is
    already the “consolidation” repo for the ecosystem (README/STATUS
    badges, `ecosystem.qmd` vignette) rather than living inside any one
    package. A `shiny-apps` sibling repo follows the same pattern you’ve
    already chosen for ecosystem-level concerns.

**Not recommended**: housing apps inside a package repo’s `inst/` —
confirmed by your own answer, kept here for the record: it works
technically
(`shiny::runApp(system.file("shiny-examples/app", package = "medfit"))`)
but only fits the “package-embedded only” coupling model you didn’t
pick, and it re-couples deploy to CRAN release cadence.

## Proposed structure

    r-packages/active/shiny-apps/          # new sibling repo, same level as medfit/, probmed/, etc.
    ├── apps/
    │   ├── mediation-explorer/            # cross-package: medfit + RMediation
    │   │   ├── app.R
    │   │   ├── renv.lock                  # per-app dependency pin (always)
    │   │   ├── manifest.json              # generated via rsconnect::writeManifest() in CI, not hand-edited
    │   │   └── README.md
    │   └── sensitivity-dashboard/         # medrobust-focused
    │       └── app.R
    ├── .github/workflows/deploy.yml       # path-filtered deploy per changed app subdir;
    │                                       # regenerates manifest.json before rsconnect::deployApp()
    ├── CLAUDE.md
    ├── .STATUS
    └── README.md                          # links out from mediationverse's ecosystem.qmd

Each app subdirectory is self-contained (own `renv.lock`) so one app’s
dependency bump doesn’t force a redeploy of the others. This isolation
comes from per-app `renv.lock` files, not from Imports/Suggests — a
plain `app.R` isn’t a package and has no DESCRIPTION.

**Escalation trigger** (added via grill, see
[GRILL-shiny-apps-location-2026-08-03.md](https://Data-Wise.github.io/mediationverse/GRILL-shiny-apps-location-2026-08-03.md)):
an app promotes from a plain `apps/<name>/app.R` to its own
golem-structured package (still inside `shiny-apps`, or spun out if it
needs independent CRAN-style release tooling) once it needs its own test
suite, versioned exports, or shared logic beyond a single file — this is
the R Shiny ecosystem’s standard pattern (`golem`: an app IS a package
that `Imports` its target package, never embedded inside it). Until an
app hits that bar, a bare `app.R` + `renv.lock` is enough.

Once an app *does* escalate to a golem package, the per-package
`Imports`/`Suggests` isolation `mediationverse` already uses (see
project memory `project_imports_suggests_selective_loading.md`)
genuinely applies — plus one addition specific to deploy tooling:
`rsconnect` (the deploy CLI) belongs in neither `Imports` nor
`Suggests`, since end users of the app never need it. Declare it in
`Config/Needs/deploy: rsconnect` instead —
`r-lib/actions/setup-r-dependencies` reads that field on CI runners
without exposing the dependency to anyone installing the app package
itself.

## Migration path (Connect Cloud)

1.  **Don’t migrate anything yet** — there’s nothing to migrate; build
    new apps directly on Connect Cloud from day one, skip shinyapps.io
    entirely. This sidesteps the whole migration-tool/redirect question
    for anything new.
2.  When the `shiny-apps` repo exists, wire deploy directly to Connect
    Cloud (check whether Connect Cloud’s GitHub-connected deploy model —
    similar to Netlify/Vercel — is live by the time you start; the
    self-serve tool referenced in the email is for *existing*
    shinyapps.io apps, so a greenfield app may have a more direct path
    already).
3.  Link from `mediationverse`’s `ecosystem.qmd` / README to each
    deployed app, same pattern as the existing pkgdown-site cross-links.

## Open questions (not blocking a structure decision)

- Which packages actually need a companion app first — pick 1 to
  prototype the monorepo pattern before assuming it generalizes to all
  5.
- Auth/access model on Connect Cloud (public vs. gated) — check pricing
  tier needed once app count is known.
- Whether `shiny-apps` should be its own GitHub repo or a directory
  inside an existing non-package “ecosystem” home — default to its own
  repo unless you already have such a home.

## Test-Plan Scaffolding

Tier: **e2e + dogfood** (new repo/deploy config, no parser/data-flow
logic yet).

`e2e` — via `shinytest2` (snapshot + interaction testing): deploy one
prototype app to Connect Cloud and confirm it loads and renders a known
output. `# TODO(author): delete if not contract-bearing`

`dogfood` — link the deployed app from `mediationverse` README/
`ecosystem.qmd` and click through from a fresh browser session.
`# TODO(author): delete if not contract-bearing`

`unit` — N/A — no parser/script logic yet, apps are UI-only at this
stage.

`integration` — N/A — no cross-command data flow yet.

`dependency` — N/A — no external dependency change yet (Connect Cloud
migration itself has no code dependency, only a hosting-target change).

## Documentation

Doc-impact score ≥3 items (rubric: guide/refcard/demo/mermaid):

**Guide** — short `CLAUDE.md` for the new `shiny-apps` repo covering
per-app structure and deploy convention (score: new repo + new
convention = high).

Refcard — N/A — score \<3, no existing refcard surface this touches.

Demo — N/A until first app is prototyped; revisit after Open Questions
item 1 is resolved.

Mermaid — N/A — structure is simple enough for a directory tree, no
diagram needed yet.

## Suggested next command

`/craft:plan docs/specs/SPEC-shiny-apps-location-2026-08-03.md` once
you’ve picked the first app to prototype — or just say “capture as spec”
now to save this recommendation as
`SPEC-shiny-apps-location-2026-08-03.md`.
