# SPEC: Shiny Apps Location & Deploy Structure

**Date**: 2026-08-03 **Status**: repo created and scaffolded — `main` +
`dev` live, protected **Repo name**: `mediation-apps` (confirmed) —
<https://github.com/Data-Wise/mediation-apps> **Chain**:
[BRAINSTORM-shiny-apps-location-2026-08-03.md](https://Data-Wise.github.io/mediationverse/BRAINSTORM-shiny-apps-location-2026-08-03.md)
→
[GRILL-shiny-apps-location-2026-08-03.md](https://Data-Wise.github.io/mediationverse/GRILL-shiny-apps-location-2026-08-03.md)
→
[REVIEW-shiny-apps-location-2026-08-03.md](https://Data-Wise.github.io/mediationverse/REVIEW-shiny-apps-location-2026-08-03.md)
→ this SPEC

## Problem

shinyapps.io is being retired in favor of Posit Connect Cloud (migration
waves start 2027-01-28; nothing breaks before then). No shiny apps exist
yet anywhere in the mediationverse ecosystem — this is a greenfield
decision on where new apps should live and how they deploy, made ahead
of building the first one.

## Decision

**New sibling repo, separate from every package repo, monorepo for apps,
standalone deploy directly to Connect Cloud** (skip shinyapps.io —
Connect Cloud confirmed open for net-new app deploys today).
Independently confirmed by the R-package-development knowledge corpus as
the “Decoupled Monorepo” pattern, recommended for exactly this shape (a
shared core package powering multiple dashboards).

## Structure

    <repo-name>/                           # new sibling repo, same level as medfit/, probmed/, etc.
    ├── apps/
    │   ├── mediation-explorer/            # cross-package: medfit + RMediation
    │   │   ├── app.R
    │   │   ├── renv.lock                  # per-app dependency pin (always)
    │   │   ├── manifest.json              # generated via rsconnect::writeManifest() in CI
    │   │   └── README.md
    │   └── sensitivity-dashboard/         # medrobust-focused
    │       └── app.R
    ├── .github/workflows/deploy.yml       # path-filtered deploy per changed app subdir;
    │                                       # regenerates manifest.json before rsconnect::deployApp()
    ├── CLAUDE.md                          # per-app structure, deploy convention,
    │                                       # "no hardcoded credentials — Sys.getenv() only"
    ├── .STATUS
    └── README.md                          # linked from mediationverse's ecosystem.qmd

## Locked decisions (from grill + review)

| Area | Decision |
|----|----|
| Branch workflow | ~~Single-integration: `main ← feature/*`~~ **Revised 2026-08-03**: multi-branch (craft-style) `main ← dev ← feature/*`, chosen by explicit user instruction after the repo was already scaffolded. `main` is PR-only (protected: 0 required reviewers, no force-push, no deletions). `dev` created, intentionally left unprotected on GitHub per ecosystem convention (local branch-guard is the enforcer). |
| Deploy secret | Per-repo GitHub Actions secret (`CONNECT_API_KEY`), not org-shared |
| Deploy granularity | Path-filtered — deploy only the app subdirectory that changed |
| Escalation trigger | App promotes from bare `app.R` to a golem package once it needs its own tests/exports/shared logic. Golem package `Imports` the target mediationverse package (never embedded in it); CI-only deploy tooling (`rsconnect`) goes in `Config/Needs/deploy`, not `Imports`/`Suggests` |
| Dependency isolation | Per-app `renv.lock`, not Imports/Suggests (that only applies once an app is golem-escalated) |
| Test tier | `e2e` via `shinytest2`, `dogfood` via a click-through from `mediationverse`’s README link |
| Repo creation | Explicitly deferred — separate authorized step, not bundled into this spec |

## Open (deferred, not blocking)

- Which package’s app to prototype first.
- Auth/access model on Connect Cloud (public vs. gated).
- Runtime-secrets policy
  ([`Sys.getenv()`](https://rdrr.io/r/base/Sys.getenv.html), `secret`
  package vault) — write into the new repo’s `CLAUDE.md` once the first
  app that needs a live data source appears; no app needs this yet.

## Repo name — options

All assume GitHub org `Data-Wise`, matching existing repo casing.

| Name | Reads as | Tradeoff |
|----|----|----|
| **`mediation-apps`** (Recommended) | Scoped to this ecosystem, plain English | Clear pairing with `mediationverse` without repeating the full word; short enough for URLs/badges |
| `shiny-apps` | Generic apps home | Ambiguous if you ever host non-mediation shiny apps (teaching, other domains) in the same place — reads as “the only shiny apps repo,” not “mediation’s” |
| `mediationverse-apps` | Explicit ecosystem tie-in | Most unambiguous, but longest; slight redundancy since `apps/` subdirs already scope by package inside |
| `med-dashboards` | Emphasizes the dashboard/explorer use case | Narrower framing — undersells apps that aren’t dashboards (e.g. a calculator-style tool) |

**Recommendation: `mediation-apps`.** Scoped enough to signal “this
belongs to the mediation ecosystem, not a catch-all,” short enough to
type/link repeatedly, and doesn’t presuppose every app is a “dashboard.”
Avoids `shiny-apps`’s risk of becoming a dumping ground for unrelated
future work outside this ecosystem.

## Addendum: repo creation & workflow revision (2026-08-03)

Executed after explicit “create the repo” confirmation:

1.  `gh repo create Data-Wise/mediation-apps` (public), scaffolded via
    `feature/initial-scaffold` per the structure above.
2.  **Empty-repo bootstrap**: GitHub requires a base-branch commit
    before a PR can target it, but a brand-new repo’s `main` has none.
    The auto-mode classifier correctly blocked an agent-initiated direct
    push to `main` — the user ran
    `git push origin feature/initial-scaffold:main` themselves, then
    branch protection was applied immediately after.
3.  **Mid-flight workflow revision**: user changed the branch pattern
    from single-integration to multi-branch (`main ← dev ← feature/*`)
    after scaffolding. Default branch fixed to `main` (was still
    pointing at the scaffold branch), `dev` created from `main`’s tip,
    scaffold branch deleted, `mediation-apps/CLAUDE.md` updated on `dev`
    to describe the new pattern. `dev` left unprotected on GitHub per
    this ecosystem’s convention (see global CLAUDE.md: “dev is NOT
    protected on GitHub — local hook is the only enforcer”).

## Next step

Pick the first app to prototype (see Open Questions above), branch a
`feature/*` off `dev` in `mediation-apps`, and scaffold
`apps/<name>/app.R` + `renv.lock` per the Structure section.
