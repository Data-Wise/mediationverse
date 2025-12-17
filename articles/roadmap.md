# Development Roadmap

## mediationverse Development Roadmap

> **Last Updated**: 2025-12-17 **Coordination Hub**: [mediation-planning
> repository](https://github.com/data-wise/mediation-planning)

This document provides a high-level overview of the development timeline
for the mediationverse ecosystem.

> **Note**: For detailed planning documents, cross-package coordination,
> and up-to-date progress tracking, see the [mediation-planning
> repository](https://github.com/data-wise/mediation-planning),
> specifically: - [Master
> Roadmap](https://github.com/data-wise/mediation-planning/blob/main/docs/ROADMAP.md) -
> Detailed timeline and status -
> [PROJECT-HUB](https://github.com/data-wise/mediation-planning/blob/main/PROJECT-HUB.md) -
> Dashboard and coordination -
> [TODOS](https://github.com/data-wise/mediation-planning/blob/main/TODOS.md) -
> Active task tracking

### Timeline Overview

    Q4 2025 (Current)    Q1 2026              Q2 2026              Q3 2026
        |                    |                    |                    |
        v                    v                    v                    v
    [Foundation]         [Integration]        [Refinement]         [Release]
     medfit MVP           Package              Documentation        CRAN
     medsim               Integration          Polishing            Submissions
     Documentation        Testing              User Testing         Launch

------------------------------------------------------------------------

### Phase 1: Foundation (Q4 2025) - ✅ **COMPLETE** (Ahead of Schedule!)

#### Objectives

Build core infrastructure and establish package foundations.

#### Milestones

##### ✅ medfit Phase 1-7 (Complete!)

Package skeleton and S7 architecture

`MediationData` and `SerialMediationData` classes

Model extraction (lm/glm, lavaan)

Comprehensive Quarto documentation

pkgdown website with Bootstrap 5

GLM fitting infrastructure

Formula interface implementation

Engine adapter pattern

Integration tests (427 tests passing)

Bootstrap methods (parametric, nonparametric, plugin)

Generic functions (coef, vcov, confint, nobs)

Effect extractors (nie, nde, te, pm, paths)

Tidyverse methods (tidy, glance)

ADHD-friendly API (med, quick)

R CMD check clean

Final CRAN submission (pending)

##### ✅ medsim (Complete)

Core simulation infrastructure

Environment detection (local/HPC)

Parallel processing with progress bars

Standard mediation scenarios

Publication-ready output

##### ✅ Documentation (Complete)

medfit vignettes (4 comprehensive guides)

probmed vignettes (integration guides)

Package websites for all packages

Unified styling (Bootstrap 5 + Litera)

#### Deliverables

- medfit MVP (extract, fit, bootstrap)
- medsim ready for use
- Complete package documentation
- GitHub Actions CI/CD for all packages

------------------------------------------------------------------------

### Phase 2: Integration (Q4 2025 - READY NOW!)

**Status**: medfit complete, ready for ecosystem integration (3 months
ahead of schedule!)

#### Objectives

Integrate dependent packages with medfit foundation.

#### Milestones

##### ✅ medfit Phase 5 (Complete)

Parametric bootstrap implementation

Nonparametric bootstrap

Plugin estimator

Extended test suite (427 tests, 100% pass rate)

Performance benchmarks

##### probmed Integration (Priority 1)

Add medfit to DESCRIPTION (Imports)

Replace extraction code with
[`medfit::extract_mediation()`](https://rdrr.io/pkg/medfit/man/extract_mediation.html)

Replace bootstrap with
[`medfit::bootstrap_mediation()`](https://rdrr.io/pkg/medfit/man/bootstrap_mediation.html)

Re-export medfit generics (nie, nde, te, pm, paths)

Add [`pmed()`](https://data-wise.github.io/probmed/reference/pmed.html)
extractor for P_med effect size

Update formula interface to use medfit

Verify backward compatibility

Update all tests and vignettes

Integration tests (probmed + medfit workflow)

##### RMediation Integration (Priority 2)

Add medfit to DESCRIPTION (Imports)

Use
[`medfit::extract_mediation()`](https://rdrr.io/pkg/medfit/man/extract_mediation.html)
for lavaan

Leverage medfit bootstrap utilities

Update
[`ci()`](https://data-wise.github.io/rmediation/reference/ci.html)
function for MediationData class

Maintain CRAN stability (careful testing)

Update documentation

Version bump to 1.5.0

##### medrobust Integration (Priority 3)

Add medfit to DESCRIPTION (Suggests)

Use for naive estimates if beneficial

Document integration patterns

Add short aliases (sens, bounds, power)

#### Deliverables

- medfit 0.1.0 release ✅ (ready, pending final merge)
- probmed 0.2.0 with medfit integration
- RMediation 1.5.0 with medfit integration
- Updated integration tests across packages

**Timeline**: Q4 2025 - Q1 2026 (Dec 2025 - Jan 2026)

------------------------------------------------------------------------

### Phase 3: Refinement (Q1 2026)

#### Objectives

Polish packages for CRAN submission and public release.

#### Milestones

##### Package Polishing

Address all R CMD check notes/warnings

Comprehensive testing on multiple platforms

Performance optimization

Memory profiling and optimization

Security audit

##### Documentation Enhancement

Complete API documentation

Add more examples

Create video tutorials

Write blog posts

Prepare manuscript drafts

##### mediationverse Meta-Package Enhancement

Package skeleton (complete)

Basic attachment logic (complete)

pkgdown website (complete)

Update attachment logic for new medfit API

Enhanced conflict detection

Improved startup message with version info

Comprehensive vignettes (getting-started, workflow)

##### User Testing

Beta testing with research collaborators

Gather feedback on API design

Address usability issues

Create FAQ documentation

#### Deliverables

- All packages pass R CMD check
- Complete documentation
- mediationverse meta-package ready
- User feedback incorporated

------------------------------------------------------------------------

### Phase 4: Release (Q2 2026)

#### Objectives

Launch packages to CRAN and announce publicly.

#### Milestones

##### CRAN Submissions

Submit medfit to CRAN

Submit probmed to CRAN (update)

Submit medrobust to CRAN

Submit mediationverse to CRAN

Address reviewer feedback

Coordinate releases

##### Public Launch

Announcement blog post

Social media campaign

R-bloggers post

Conference presentations

Workshop materials

##### Long-term Maintenance

Establish release schedule

Set up community guidelines

Create issue templates

Establish code review process

Plan future enhancements

#### Deliverables

- All packages on CRAN
- Public announcement
- Workshop materials
- Maintenance plan

------------------------------------------------------------------------

### Post-Release: Future Enhancements

#### medfit Extensions

- **Four-way Decomposition**: VanderWeele interaction support
- **Estimation Engines**: CMAverse adapters (g-formula, IPW)
- **Advanced Models**: lmer, brms engines
- **Targeted Learning**: tmle3 adapter
- **Machine Learning**: DoubleML integration

#### New Packages (Tentative)

- **medcausal**: Causal inference tools
- **medpower**: Power analysis specialized for mediation
- **medviz**: Advanced visualization
- **medML**: Machine learning for mediation

#### Integration Priorities

1.  **Q4 2026**: lmer engine for multilevel mediation
2.  **Q1 2027**: CMAverse integration (g-formula, IPW)
3.  **Q2 2027**: Four-way decomposition
4.  **Q3 2027**: Targeted learning (tmle3)

------------------------------------------------------------------------

### Success Metrics

#### Technical Metrics

- All packages pass R CMD check on CRAN

- 90% code coverage across packages

- \<500ms for typical mediation analysis

- Zero critical bugs in production

#### Adoption Metrics

- 1000+ downloads in first quarter
- 10+ citations in first year
- Active user community (GitHub stars, issues)
- Positive feedback from beta testers

#### Quality Metrics

- Comprehensive documentation
- Responsive issue resolution (\<48h)
- Regular releases (quarterly)
- Active maintenance

------------------------------------------------------------------------

### Risk Assessment

#### Technical Risks

| Risk                 | Probability | Impact | Mitigation                                 |
|----------------------|-------------|--------|--------------------------------------------|
| API breaking changes | Medium      | High   | Extensive testing, deprecation warnings    |
| Performance issues   | Low         | Medium | Benchmarking, profiling                    |
| CRAN rejection       | Low         | High   | Early submission, address feedback quickly |
| S7 stability         | Low         | High   | Track S7 development, contribute fixes     |

#### Project Risks

| Risk                 | Probability | Impact | Mitigation                           |
|----------------------|-------------|--------|--------------------------------------|
| Delayed integration  | Medium      | Medium | Modular design, parallel development |
| Scope creep          | Medium      | Medium | Strict MVP definition, phase gates   |
| Resource constraints | Low         | High   | Prioritize core features             |

------------------------------------------------------------------------

### Communication Plan

#### Regular Updates

- **Monthly**: Progress updates on GitHub Discussions
- **Quarterly**: Blog posts on major milestones
- **Ad-hoc**: Announce breaking changes early

#### Channels

- GitHub Issues/Discussions
- R-bloggers
- Social media (Twitter/Mastodon)
- Mailing list (future)

------------------------------------------------------------------------

### Contact & Feedback

**Project Lead**: Davood Tofighi (<dtofighi@gmail.com>)

**Provide Feedback**: - [GitHub
Discussions](https://github.com/data-wise/mediationverse/discussions) -
[Feature
Requests](https://github.com/data-wise/mediationverse/issues/new) -
Email: <dtofighi@gmail.com>

------------------------------------------------------------------------

### See Also

For detailed planning, cross-package coordination, and real-time
updates:

- [**mediation-planning
  repository**](https://github.com/data-wise/mediation-planning) -
  Coordination hub
  - [Master
    Roadmap](https://github.com/data-wise/mediation-planning/blob/main/docs/ROADMAP.md) -
    Detailed timeline
  - [PROJECT-HUB](https://github.com/data-wise/mediation-planning/blob/main/PROJECT-HUB.md) -
    Dashboard
  - [TODOS](https://github.com/data-wise/mediation-planning/blob/main/TODOS.md) -
    Task tracking
  - [IDEAS](https://github.com/data-wise/mediation-planning/blob/main/IDEAS.md) -
    Future enhancements

Individual packages: - [medfit](https://data-wise.github.io/medfit/) -
Foundation package - [probmed](https://data-wise.github.io/probmed/) -
Probabilistic mediation -
[RMediation](https://data-wise.github.io/RMediation/) - Distribution
methods (CRAN)

------------------------------------------------------------------------

**Next Review**: End of Q4 2025 (Dec 31, 2025)
