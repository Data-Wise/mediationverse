# BRAINSTORM: mediationverse — tidyverse-style functions & settings

**Date:** 2026-06-19  
**Mode:** feature | **Depth:** default

---

## What already exists

| Function | Status | Notes |
|---|---|---|
| `mediationverse_packages()` | ✅ | Good; has print method |
| `mediationverse_update()` | ✅ ⚠ | Stale: treats medfit/RMediation as GitHub-only — both now on CRAN |
| `mediationverse_conflicts()` | ✅ | Exists (likely thin) |
| `.onAttach` startup message | ✅ | cli-based, shows medfit version |
| `mediationverse_attach()` | ✅ internal | Selective-load: only medfit by default |

---

## Quick Wins (< 1 hr each)

### 1. Fix `mediationverse_update()` CRAN source map

medfit and RMediation are now on CRAN. Split should be:

```r
cran_pkgs   <- c("RMediation", "medfit")
github_pkgs <- c(probmed = "data-wise/probmed",
                 medrobust = "data-wise/medrobust",
                 medsim    = "data-wise/medsim")
```

Also add `upgrade = c("ask", "always", "never")` forwarded to `pak::pak()`.

---

### 2. `mediationverse_sitrep()` — situation report

```r
mediationverse_sitrep()
# ── mediationverse situation report ──────────────────────────
# ✔ R       4.4.1
# ✔ medfit  0.2.1  (CRAN — current)
# ✔ RMediation 1.5.0 (CRAN — current)
# ✗ probmed    0.1.0 (GitHub — dev; CRAN not available)
# ✗ medsim  dev (GitHub — no release tag)
# ✗ medrobust not installed
# ────────────────────────────────────────────────────────────
# Run mediationverse_update() to install missing packages.
```

Fields: package, installed version, source (CRAN/GitHub/not installed), currency.

---

### 3. Global options — `mv_options()` and `mv_get_option()`

```r
# Set once at top of script or in .Rprofile
mv_options(
  ci_type = "MC",
  level   = 0.95,
  n_mc    = 1e5,
  quiet   = FALSE
)

# .Rprofile equivalents
options(mediationverse.ci_type  = "MC")
options(mediationverse.level    = 0.95)
options(mediationverse.quiet    = TRUE)
```

These feed into `ci()` and `medci()` as fallback defaults. Lets analysts write:

```r
mv_options(ci_type = "dop", level = 0.99)
ci(fit)   # uses dop + 0.99 without repeating args
```

---

## Medium Effort (2–4 hrs each)

### 4. `mediationverse_news(n = 5)` — aggregate NEWS

Aggregate last n NEWS entries from all installed packages, newest first.

```r
mediationverse_news(n = 3)
# ── RMediation 1.5.0 ─────────────────────────────────────────
# * Serial mediation via medfit (ci.SerialMediationData)
# * r-universe binary available
# ── medfit 0.2.1 ─────────────────────────────────────────────
# * extract_mediation() now handles parallel chains
```

Implemented with `utils::news(package = pkg)` + `head()`.

---

### 5. `mediationverse_citations()` — citation block

```r
mediationverse_citations(style = "apa")
# Tofighi, D., & MacKinnon, D. P. (2011). RMediation...
# [medfit citation]

mediationverse_citations(style = "bibtex")
# @Manual{RMediation, ...}
```

Wraps `utils::citation()` per installed package. Analysts consistently miss citing all packages.

---

### 6. `mediation_pipeline()` — fit → extract → CI → interpret ⭐

Flagship feature. A lazy pipeline object chaining the ecosystem layers:

```r
pipeline <- mediation_pipeline() |>
  add_fit(lavaan::sem(model, data = dat)) |>
  add_extraction(treatment = "X",
                 mediator  = c("M1", "M2"),
                 outcome   = "Y") |>
  add_ci(type = "MC", level = 0.95)

fit_pipeline(pipeline)
# ── Mediation Pipeline ────────────────────────────────────────
# Fit:        lavaan SEM (800 obs)
# Extraction: X → {M1, M2} → Y  [serial, 2 mediators]
# Indirect:   0.209  95% MC CI [0.170, 0.251]
# ─────────────────────────────────────────────────────────────
# ✔ Significant indirect effect (CI excludes 0)
```

Returns an S7 `MediationPipeline` object with tidy/print/summary methods.

---

### 7. `mediationverse_doctor()` — environment diagnostic

```r
mediationverse_doctor()
# ✔ R 4.4.1
# ✔ medfit 0.2.1 compatible with RMediation 1.5.0
# ✗ OpenMx not installed → mbco() will fail
#   Fix: install.packages("OpenMx", repos = "https://openmx.ssri.psu.edu/packages/")
# ✔ lavaan 0.6-17 (extract_mediation() fully supported)
```

Checks: R version, package compatibility, optional deps (OpenMx, lavaan), known conflicts.

---

## Long-term / Creative

### 8. `mediate()` — unified entry point

One function for newcomers:

```r
result <- mediate(
  data      = dat,
  treatment = "X",
  mediator  = c("M1", "M2"),
  outcome   = "Y",
  method    = "lavaan",   # or "lm", "glm"
  ci_type   = "MC"
)
```

Internally calls medfit + RMediation. The "Hello World" of the ecosystem.

---

### 9. `.Rprofile` settings documentation

Document (and test) that users can suppress startup noise with:

```r
# ~/.Rprofile
options(mediationverse.quiet   = TRUE)
options(mediationverse.ci_type = "MC")
options(mediationverse.level   = 0.95)
```

Add vignette section: "Customising your mediationverse session".

---

### 10. `mediationverse_attach_all()` — load everything

```r
library(mediationverse)           # loads medfit only (current)
mediationverse_attach_all()       # also loads RMediation, probmed, etc.
```

Useful for teaching contexts and power users who want the full namespace.

---

## Recommended Path

1. **#1 Fix update sources** (30 min) — correctness fix, CRAN-ready
2. **#2 `mediationverse_sitrep()`** (1 hr) — highest user value, models tidyverse
3. **#3 `mv_options()`** (1 hr) — unlocks global defaults for ci()/medci()
4. **#6 `mediation_pipeline()`** (future session) — flagship feature

---

*Generated: 2026-06-19 | Mode: feature/default | mediationverse v0.0.0.9000*
