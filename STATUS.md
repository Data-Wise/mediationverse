# Mediationverse Ecosystem Status

> Centralized monitoring for all mediationverse packages

**Last Updated**: 2026-05-31

> 📋 **Recent Activity (2026-05-31)**: medfit ↔ RMediation covariance integration landed. Merged: [RMediation#4](https://github.com/Data-Wise/rmediation/pull/4) (→develop — name-based path covariance extraction in `ci()`), [medfit#19](https://github.com/Data-Wise/medfit/pull/19) (→dev — Blocker A: lavaan off-diagonal covariances + print.mediation_effect S3 dispatch fix), [mediation-planning#2](https://github.com/Data-Wise/mediation-planning/pull/2) (→main — ecosystem proposal + covariance specs). **Remaining:** medfit **Blocker B** (serial mediation extractor) before RMediation's serial lavaan pipeline is end-to-end. See [master roadmap](https://github.com/Data-Wise/mediation-planning/blob/main/docs/ROADMAP.md).
>
> _Prior (2026-05-09): branch protection across all 5 repos; Imports → Suggests (mediationverse#2)._

---

## Package Status Overview

| Package | Lifecycle | Repo Status | Build | Website | R-hub | Coverage | CRAN |
|---------|-----------|-------------|-------|---------|-------|----------|------|
| [medfit](https://github.com/data-wise/medfit) | [![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) | [![Repo Status](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) | [![R-CMD-check](https://github.com/data-wise/medfit/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/medfit/actions/workflows/R-CMD-check.yaml) | [![Website Status](https://github.com/data-wise/medfit/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/medfit/actions/workflows/pkgdown.yaml) | [![R-hub](https://github.com/data-wise/medfit/actions/workflows/rhub.yaml/badge.svg)](https://github.com/data-wise/medfit/actions/workflows/rhub.yaml) | [![Codecov](https://codecov.io/gh/data-wise/medfit/graph/badge.svg)](https://codecov.io/gh/data-wise/medfit) | Not on CRAN |
| [probmed](https://github.com/data-wise/probmed) | [![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable) | [![Repo Status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) | [![R-CMD-check](https://github.com/data-wise/probmed/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/probmed/actions/workflows/R-CMD-check.yaml) | [![Website Status](https://github.com/data-wise/probmed/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/probmed/actions/workflows/pkgdown.yaml) | [![R-hub](https://github.com/data-wise/probmed/actions/workflows/rhub.yaml/badge.svg)](https://github.com/data-wise/probmed/actions/workflows/rhub.yaml) | [![Codecov](https://codecov.io/gh/data-wise/probmed/graph/badge.svg)](https://codecov.io/gh/data-wise/probmed) | Not on CRAN |
| [RMediation](https://github.com/data-wise/rmediation) | [![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable) | [![Repo Status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) | [![R-CMD-check](https://github.com/data-wise/rmediation/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/rmediation/actions/workflows/R-CMD-check.yaml) | [![Website Status](https://github.com/data-wise/rmediation/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/rmediation/actions/workflows/pkgdown.yaml) | [![R-hub](https://github.com/data-wise/rmediation/actions/workflows/rhub.yaml/badge.svg)](https://github.com/data-wise/rmediation/actions/workflows/rhub.yaml) | [![Codecov](https://codecov.io/gh/data-wise/rmediation/graph/badge.svg)](https://codecov.io/gh/data-wise/rmediation) | [![CRAN](https://www.r-pkg.org/badges/version/RMediation)](https://CRAN.R-project.org/package=RMediation) |
| [medrobust](https://github.com/data-wise/medrobust) | [![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) | [![Repo Status](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) | [![R-CMD-check](https://github.com/data-wise/medrobust/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/medrobust/actions/workflows/R-CMD-check.yaml) | [![Website Status](https://github.com/data-wise/medrobust/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/medrobust/actions/workflows/pkgdown.yaml) | [![R-hub](https://github.com/data-wise/medrobust/actions/workflows/rhub.yaml/badge.svg)](https://github.com/data-wise/medrobust/actions/workflows/rhub.yaml) | [![Codecov](https://codecov.io/gh/data-wise/medrobust/graph/badge.svg)](https://codecov.io/gh/data-wise/medrobust) | Not on CRAN |
| [medsim](https://github.com/data-wise/medsim) | [![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) | [![Repo Status](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) | [![R-CMD-check](https://github.com/data-wise/medsim/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/medsim/actions/workflows/R-CMD-check.yaml) | [![Website Status](https://github.com/data-wise/medsim/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/medsim/actions/workflows/pkgdown.yaml) | [![R-hub](https://github.com/data-wise/medsim/actions/workflows/rhub.yaml/badge.svg)](https://github.com/data-wise/medsim/actions/workflows/rhub.yaml) | [![Codecov](https://codecov.io/gh/data-wise/medsim/graph/badge.svg)](https://codecov.io/gh/data-wise/medsim) | Not on CRAN |
| [mediationverse](https://github.com/data-wise/mediationverse) | [![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) | [![Repo Status](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) | [![R-CMD-check](https://github.com/data-wise/mediationverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/mediationverse/actions/workflows/R-CMD-check.yaml) | [![Website Status](https://github.com/data-wise/mediationverse/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/mediationverse/actions/workflows/pkgdown.yaml) | [![R-hub](https://github.com/data-wise/mediationverse/actions/workflows/rhub.yaml/badge.svg)](https://github.com/data-wise/mediationverse/actions/workflows/rhub.yaml) | - | Not on CRAN |

---

## Quick Links

### Package Websites
- [medfit](https://data-wise.github.io/medfit/)
- [probmed](https://data-wise.github.io/probmed/)
- [RMediation](https://data-wise.github.io/rmediation/)
- [medrobust](https://data-wise.github.io/medrobust/)
- [medsim](https://data-wise.github.io/medsim/)
- [mediationverse](https://data-wise.github.io/mediationverse/)

### GitHub Actions
- [medfit workflows](https://github.com/data-wise/medfit/actions)
- [probmed workflows](https://github.com/data-wise/probmed/actions)
- [RMediation workflows](https://github.com/data-wise/rmediation/actions)
- [medrobust workflows](https://github.com/data-wise/medrobust/actions)
- [medsim workflows](https://github.com/data-wise/medsim/actions)
- [mediationverse workflows](https://github.com/data-wise/mediationverse/actions)

### Code Coverage
- [medfit on Codecov](https://codecov.io/gh/data-wise/medfit)
- [medrobust on Codecov](https://codecov.io/gh/data-wise/medrobust)

---

## Standard Badge Template

All packages should use this badge order in their README.md:

```markdown
<!-- badges: start -->
[![Lifecycle: {status}](https://img.shields.io/badge/lifecycle-{status}-{color}.svg)](https://lifecycle.r-lib.org/articles/stages.html#{status})
[![Repo Status](https://www.repostatus.org/badges/latest/{status}.svg)](https://www.repostatus.org/#{status})
[![CRAN status](https://www.r-pkg.org/badges/version/{package})](https://CRAN.R-project.org/package={package})
[![R-CMD-check](https://github.com/data-wise/{package}/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/data-wise/{package}/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/data-wise/{package}/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/data-wise/{package}/actions/workflows/pkgdown.yaml)
[![Codecov](https://codecov.io/gh/data-wise/{package}/graph/badge.svg)](https://codecov.io/gh/data-wise/{package})
<!-- badges: end -->
```

### Lifecycle Options
- `experimental` (orange) - Under active development
- `stable` (green) - Ready for production use
- `deprecated` (orange) - No longer recommended
- `superseded` (blue) - Replaced by newer package

### Repo Status Options
- `wip` - Work in Progress
- `active` - Active development
- `inactive` - Not actively maintained
- `unsupported` - No longer supported

---

## Current Issues

### medfit
- Status: Under active development; dev has Blocker A (PR #19) + Blocker B **lavaan serial extractor** (PR #20) merged; CI fully green (lint debt cleared, PR #21).
- Issues: Blocker B remaining work = the **lm/sequential-regression** serial path only — decision-complete and spec'd (`medfit/planning/specs/SPEC-lm-serial-extractor-2026-05-31.md`). The lavaan serial pipeline is verified end-to-end against RMediation. See `mediation-planning/specs/MEDFIT-COVARIANCE-EXTRACTION-BLOCKERS-SPEC.md`.

### probmed
- Status: Stable, ready for integration testing
- Issues: None

### RMediation
- Status: On CRAN (1.4.0); develop has medfit covariance integration (PR #4 merged 2026-05-31)
- Issues: None blocking. v1.5.0 needs medfit on CRAN (Suggests → Imports). Serial lavaan path is unblocked (medfit Blocker B lavaan merged + verified end-to-end); only lm-fit serial chains await medfit's lm serial extractor.

### medrobust
- Status: Under active development
- Issues: None currently blocking

### medsim
- Status: Core features complete
- Issues: ⚠️ R-CMD-check failing (optional Suggests packages not available)
  - Expected: Will resolve when medfit/probmed published
  - Workaround: Tests skip gracefully when packages unavailable

### mediationverse
- Status: Meta-package skeleton complete
- Issues: None

---

## Monitoring Best Practices

1. **Check this page weekly** for build failures
2. **Badge colors indicate status**:
   - 🟢 Green = Passing
   - 🔴 Red = Failing
   - 🟡 Orange = Warning/In Progress
3. **Click badges** to see detailed workflow logs
4. **Priority**: Fix red badges before release
5. **Expected failures**: Some packages may fail until dependencies published

---

## Release Readiness Checklist

Before CRAN submission, ensure:
- [ ] All R-CMD-check badges are green
- [ ] pkgdown website builds successfully
- [ ] Code coverage >80% (if applicable)
- [ ] All dependencies available on CRAN
- [ ] NEWS.md updated with release notes
- [ ] Version number incremented appropriately

---

## Contact

**Maintainer**: Davood Tofighi (dtofighi@gmail.com)
**ORCID**: [0000-0001-8523-7776](https://orcid.org/0000-0001-8523-7776)
