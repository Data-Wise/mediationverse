# Design notes: `mediate()` / `mediation_pipeline()` for mediationverse

Date: 2026-11-17 | Status: design only, no code. Origin: `BRAINSTORM-tidyverse-functions-2026-06-19.md`
items 6 and 8, deferred from 0.2.0 and 0.3.0.

## Recommendation

**Do not build `mediate()` or a pipeline object in mediationverse.** The unified entry point already
exists upstream: `medfit::med()`. A second one in the meta-package would duplicate it, and would have to
track a package that is moving fast. Ship a docs-only recipe instead (option C below) and revisit only if
the exit criteria in the last section are met.

## Evidence (read 2026-11-17 from the installed and source packages, not from memory)

- `medfit::med(data, treatment, mediator, outcome, covariates = NULL, boot = FALSE, n_boot = 1000L,
  seed = NULL, ...)` is exported (also `quick`, `fit_mediation`, `extract_mediation`,
  `bootstrap_mediation`, `fit_sem`, `decompose`, `joint_effects`, `mbco_sem`, `te`, `nde`, `nie`, `pm`,
  `paths`). That is the "hello world" function the brainstorm wanted `mediate()` to be: data, three
  variable names, optional covariates and bootstrap.
- `medfit::fit_mediation(formula_y, formula_m, data, treatment, mediator, engine = "glm", family_y,
  family_m, weights, se_type, engine_args, m_star, cluster, model, ...)` is the lower-level entry; the
  `model` argument is new (0.18 line), so the surface is still changing.
- Version skew in the wild: medfit 0.7.0 is installed on the dev machine while 0.18.0 is current (a gap of
  eleven minor versions in about a month). A wrapper written against one version breaks on another.
- Name collisions already exist: `extract_mediation` is exported by both medfit and probmed, and `tidy` by
  RMediation and missingmed (the two conflicts `mediationverse_conflicts()` reports). Adding `mediate()`
  adds a name with no sibling owner.
- The other members hang off medfit objects: RMediation `ci_mediation_data()` /
  `ci_serial_mediation_data()`, probmed `pmed()`, missingmed `run()`. A pipeline would have to chain
  four different return types; none share a common interface beyond medfit's S7 data classes.

## Options

| Option | What | Cost | Risk |
|---|---|---|---|
| A. Thin `mediate()` | Forward to `medfit::med()` and add a CI step via RMediation | Small | Duplicates `med()`; breaks whenever either signature moves |
| B. S7 `MediationPipeline` | Lazy object with `add_fit()`, `add_ci()`, `fit_pipeline()` | Large | New public API surface owned by the meta-package; four-package coupling; version skew |
| **C. Docs-only recipe (recommended)** | A short article and README snippet showing `med()` then `RMediation::ci_mediation_data()` and `probmed::pmed()` | Small | None for the API; docs can drift, so show only calls that run in CI |

## Option C sketch

One article section, "A first analysis in four calls", using only exported functions verified above, run in
the vignette build against the installed versions, with `eval = FALSE` for anything that needs a sibling not
installed on CI. No new exports, no new dependencies.

## Exit criteria for building A or B later

1. medfit has had no breaking change to `med()` / `fit_mediation()` signatures across three consecutive
   releases (check NEWS with `mediationverse_news()`).
2. At least one sibling (probmed, RMediation or missingmed) agrees on a shared result interface, so a
   pipeline has something stable to chain.
3. A concrete user need beyond what `med()` covers, written as an issue.
4. A SPEC in `planning/` with the argument surface, return class and test plan, before any code.

## Out of scope here

`mv_options()`: still no sibling reads a `mediationverse.*` option (checked 2026-11-17: medfit reads only its
own `medfit.*` options). Revisit when criterion 2 produces shared defaults.
