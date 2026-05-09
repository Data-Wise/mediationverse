# Selective Loading Test Results

**Date**: 2025-12-15 **Package**: mediationverse 0.0.0.9000
**Strategy**: Option 2 - Selective Loading (only medfit by default)

------------------------------------------------------------------------

## ✅ Test Results

### 1. Startup Message Test

**Command**: `devtools::load_all()`

**Output**:

    ℹ Loading mediationverse
    ── Attaching mediationverse ────────────────────────────────────── 0.0.0.9000 ──
    ✔ medfit 0.1.0 (foundation package)
    ℹ Use library(probmed) for P_med effect size
    ℹ Use library(RMediation) for DOP/MBCO inference
    ℹ Use library(medrobust) for sensitivity analysis
    ℹ Use library(medsim) for simulation utilities
    ────────────────────────────────────────────────────────────────────────────────

**Result**: ✅ PASS - Shows only medfit loaded - Displays helpful
information about other packages - Clean, informative message

------------------------------------------------------------------------

### 2. Package Attachment Test

**Command**: `grep('mediationverse|medfit', search(), value = TRUE)`

**Output**:

    [1] "package:medfit"         "package:mediationverse"

**Result**: ✅ PASS - Only mediationverse and medfit attached - probmed,
RMediation, medrobust, medsim NOT attached - Selective loading working
correctly

------------------------------------------------------------------------

### 3. Package Status Function Test

**Command**:
[`mediationverse_packages()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_packages.md)

**Output**:

    ── mediationverse packages ─────────────────────────────────────────────────────
    ✔ mediationverse 0.0.0.9000 (attached)
    ✔ medfit 0.1.0 (attached)
    ✔ probmed 0.0.0.9000
    ✔ RMediation 1.4.0
    ✔ medrobust 0.1.0.9000
    ✔ medsim 0.0.0.9000

**Result**: ✅ PASS - Shows all packages installed - Correctly marks
only mediationverse and medfit as attached - Clear visual distinction

------------------------------------------------------------------------

### 4. Conflict Detection Test

#### 4a. With Only medfit Loaded

**Command**:
[`mediationverse_conflicts()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_conflicts.md)

**Output**:

    ℹ No conflicts possible with fewer than 2 packages loaded.

**Result**: ✅ PASS - Correctly detects no conflicts with minimal
loading - Clean namespace achieved

#### 4b. With Multiple Packages Loaded

**Setup**:

``` r

library(probmed)
library(RMediation)
```

**Command**:
[`mediationverse_conflicts()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_conflicts.md)

**Output**:

    ── mediationverse conflicts ────────────────────────────────────────────────────
    6 conflicts found:

    `extract_mediation()` from medfit, probmed (using medfit)
    `.__T__$:base()` from medfit, RMediation (using medfit)
    `.__T__[:base()` from medfit, RMediation (using medfit)
    `.__T__[<-:base()` from medfit, RMediation (using medfit)
    `.__T__[[<-:base()` from medfit, RMediation (using medfit)
    `.__T__$<-:base()` from medfit, RMediation (using medfit)

    ℹ Use `package::function()` to call a specific version

**Result**: ✅ PASS - Detects real conflict:
[`extract_mediation()`](https://data-wise.github.io/medfit/reference/extract_mediation.html)
exists in both medfit and probmed - Shows which version is used (medfit
wins) - Internal S7 method conflicts are expected and don’t affect
users - Provides helpful guidance to use `package::function()` syntax

------------------------------------------------------------------------

## 📊 Summary

### ✅ All Tests Passed

| Test                          | Status  | Notes                          |
|-------------------------------|---------|--------------------------------|
| Startup message               | ✅ PASS | Clean, informative             |
| Selective loading             | ✅ PASS | Only medfit attached           |
| Package status                | ✅ PASS | Utility function works         |
| Conflict detection (minimal)  | ✅ PASS | No conflicts with medfit only  |
| Conflict detection (multiple) | ✅ PASS | Correctly identifies conflicts |

------------------------------------------------------------------------

## 🎯 Benefits Demonstrated

1.  **Clean Namespace**
    - Only medfit loaded by default
    - Minimal function conflicts
    - Users control what’s loaded
2.  **Helpful Guidance**
    - Startup message guides users to other packages
    - Conflict detection provides clear information
    - Easy to understand which package to use
3.  **Utility Functions Work**
    - [`mediationverse_packages()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_packages.md)
      shows ecosystem status
    - [`mediationverse_conflicts()`](https://Data-Wise.github.io/mediationverse/reference/mediationverse_conflicts.md)
      detects potential issues
    - Both provide actionable information

------------------------------------------------------------------------

## 🔄 Coordination Status

### ✅ Aligned with medfit

- Follows COORDINATION-BRAINSTORM.md recommendation (Option 2)
- medfit always loaded (foundation package)
- Other packages loaded explicitly as needed
- Integration ready when medfit v0.1.0 releases

### 📋 Next Steps

1.  ✅ Documentation updated (README, vignettes)
2.  ✅ Loading mechanism tested
3.  ⏳ Wait for medfit v0.1.0 stabilization
4.  ⏳ Integration testing with probmed
5.  ⏳ Final version bump to 0.1.0

------------------------------------------------------------------------

## 📝 Files Modified

**Core Loading**: - `R/attach.R` - Selective loading implementation -
`R/zzz.R` - Startup message

**Documentation**: - `README.md` - Loading examples, architecture
diagram - `vignettes/getting-started.qmd` - Tutorial updates -
`vignettes/mediationverse-workflow.qmd` - Workflow updates

**Testing**: - This file - Test documentation

------------------------------------------------------------------------

**Last Updated**: 2025-12-15 **Status**: All tests passing, ready for
integration
