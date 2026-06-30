# The mediationverse Ecosystem

## What the ecosystem is

The mediationverse builds outward from a shared foundation — **medfit**
(S7 data classes, model extraction, fitting, and bootstrap inference) —
that the analysis packages build on. The **mediationverse** meta-package
ties them together with selective loading: only `medfit` loads by
default, and
[`library(mediationverse)`](https://Data-Wise.github.io/mediationverse/)
makes the others available without forcing every dependency into memory.

## Packages

| Package | Role | Purpose | Website | CRAN |
|----|----|----|----|----|
| [**mediationverse**](https://data-wise.github.io/mediationverse/) | Umbrella | Meta-package, selective loading | [site](https://data-wise.github.io/mediationverse/) | Not yet |
| [**medfit**](https://data-wise.github.io/medfit/) | Foundation | S7 data classes, model extraction (`lm`/`glm`/`lavaan`), fitting, bootstrap | [site](https://data-wise.github.io/medfit/) | ✅ |
| [**probmed**](https://data-wise.github.io/probmed/) | Application | P_med probabilistic effect size | [site](https://data-wise.github.io/probmed/) | Not yet |
| [**RMediation**](https://data-wise.github.io/rmediation/) | Application | Confidence intervals (DOP, MBCO, Monte Carlo) | [site](https://data-wise.github.io/rmediation/) | ✅ |
| [**medrobust**](https://data-wise.github.io/medrobust/) | Application | Sensitivity analysis for unmeasured confounding | [site](https://data-wise.github.io/medrobust/) | Not yet |
| [**medsim**](https://data-wise.github.io/medsim/) | Support | Simulation infrastructure for data-generating scenarios | [site](https://data-wise.github.io/medsim/) | Not yet |

### Planned

| Package | Role | Purpose |
|----|----|----|
| **missingmed** | Application | Missing-data mediation (multiple imputation + IPW) — requires `medfit >= 0.3.0` |

`missingmed` doesn’t have a repository or website yet; it’s tracked here
so the ecosystem map stays accurate as it lands.

## Live status

Per-package CI/coverage/CRAN badges are maintained as a dashboard, not
duplicated here (badge walls drift fast when hand-copied into prose):

- [Package Status
  Dashboard](https://github.com/data-wise/mediationverse/blob/main/STATUS.md)
- Live local check: `cd ~/projects/r-packages && /rforge:status` (or
  `:thorough`)

## Roadmap & planning

Direction, phases, and active cross-package tasks live in the
[mediation-planning
hub](https://github.com/data-wise/mediation-planning) and the
[Development
Roadmap](https://Data-Wise.github.io/mediationverse/articles/roadmap.md)
article — not duplicated here.

## Get involved

- [Contributing
  Guide](https://Data-Wise.github.io/mediationverse/articles/contributing.md)
- [Report an issue](https://github.com/data-wise/mediationverse/issues)
- [Request a
  feature](https://github.com/data-wise/mediationverse/issues/new)
