# Development Roadmap

## mediationverse Development Roadmap

> **Authoritative, always-current roadmap:** the [mediation-planning
> hub](https://github.com/data-wise/mediation-planning). This page is a
> high-level orientation only — detailed phases, milestones, and status
> are maintained in the hub (and generated live by tooling), so they are
> not duplicated here where they would drift.

### What the ecosystem is

See the
[Ecosystem](https://Data-Wise.github.io/mediationverse/articles/ecosystem.md)
article for the package map, roles, and status — not duplicated here.

### Direction (high level)

1.  **Foundation** — medfit feature-complete: extraction (lm/glm,
    lavaan), GLM fitting, bootstrap, S7 classes, plus tidyverse and
    ADHD-friendly APIs.
2.  **Integration** — analysis packages consume medfit’s shared
    infrastructure instead of duplicating it (the probmed and RMediation
    integrations have landed).
3.  **CRAN** — medfit leads the submission sequence; dependents follow
    in dependency order.
4.  **Beyond the MVP** — interaction (four-way) decomposition,
    estimation-engine adapters (CMAverse g-formula / IPW), multilevel
    (`lmer`) and Bayesian (`brms`) engines, and targeted learning
    (`tmle3`).

### Current status & detailed plan

Maintained in the hub so it stays current (rather than drifting in this
vignette):

- [Master
  Roadmap](https://github.com/data-wise/mediation-planning/blob/main/docs/ROADMAP.md)
  — detailed phases and timeline
- [PROJECT-HUB](https://github.com/data-wise/mediation-planning/blob/main/PROJECT-HUB.md)
  — dashboard and current focus
- [TODOS](https://github.com/data-wise/mediation-planning/blob/main/TODOS.md)
  — active cross-package tasks
- Live per-package health: `cd ~/projects/r-packages && /rforge:status`

### See also

- [Ecosystem](https://Data-Wise.github.io/mediationverse/articles/ecosystem.md)
  — package map, roles, websites

### Feedback

**Project Lead:** Davood Tofighi (<dtofighi@gmail.com>) · [GitHub
Discussions](https://github.com/data-wise/mediationverse/discussions) ·
[Feature
Requests](https://github.com/data-wise/mediationverse/issues/new)
