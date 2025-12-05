Run comprehensive pre-commit checks for mediationverse

This command runs a full suite of quality checks before committing changes.

## Phase 1: Code Style and Quality

### Automatic Formatting
```r
# Auto-format all R files
styler::style_pkg()
```

### Static Analysis
```r
# Run linter
lintr::lint_package()
```

### Spelling Check
```r
# Check spelling in documentation
spelling::spell_check_package()
```

**Review all linter warnings and spelling errors**
- Fix critical issues (errors, warnings)
- Consider fixing notes and suggestions
- Document intentional deviations in CLAUDE.md

## Phase 2: Documentation

### Update Documentation
```r
# Generate documentation from roxygen2
devtools::document()
```

### Check Documentation
```r
# Verify all exports documented
devtools::check_man()

# Build documentation site
pkgdown::build_reference()
```

**Verify**:
- [ ] All exported functions have complete documentation
- [ ] Examples run successfully
- [ ] No broken cross-references
- [ ] Package website builds cleanly

## Phase 3: Testing

### Run Test Suite
```r
# Run all tests
devtools::test()
```

**Expected output**: All tests pass (0 failures, 0 warnings)

### Check Coverage
```r
# Generate coverage report
cov <- covr::package_coverage()
print(cov)
covr::report(cov)
```

**Requirements**:
- [ ] Overall coverage >80%
- [ ] All new functions have tests
- [ ] Critical statistical code has 100% coverage

### Test with Different R Versions (if available)
```r
# Check which R versions are available
system("R --version")
```

## Phase 4: R CMD Check

### Full Package Check
```r
# Comprehensive CRAN-like check
check_results <- devtools::check(
  document = TRUE,
  args = c("--as-cran"),
  error_on = "warning"
)
```

**Must achieve**: 
- ✓ 0 errors
- ✓ 0 warnings  
- ✓ 0 notes (preferred, but some notes OK)

### Common Issues to Review

**Errors** (Must fix):
- Missing dependencies in DESCRIPTION
- Invalid NAMESPACE
- Failing examples or tests
- Invalid R code syntax

**Warnings** (Must fix):
- Undocumented exports
- S3 methods not registered
- Non-standard file/directory names
- Missing or broken URLs

**Notes** (Review):
- New maintainer (OK for updates)
- Package size (check if bloated)
- Non-standard directories (may be OK)
- Possibly mis-spelled words (verify)

## Phase 5: Additional Quality Checks

### Good Practices Check
```r
# Comprehensive package quality check
goodpractice::gp()
```

**Review recommendations for**:
- Package structure
- Code complexity
- Function length
- Cyclomatic complexity
- Documentation completeness

### Dependency Check
```r
# Check for unused dependencies
usethis::use_tidy_description()

# Review DESCRIPTION file
cat(readLines("DESCRIPTION"), sep = "\n")
```

**Verify**:
- [ ] All imports are used
- [ ] No unnecessary dependencies
- [ ] Versions specified where needed
- [ ] License is appropriate

## Phase 6: Build and Install

### Build Source Package
```r
# Create source tarball
devtools::build()
```

### Install and Load
```r
# Install fresh from source
devtools::install()

# Load and verify
library(mediationverse)

# Quick smoke test
packageVersion("mediationverse")
ls("package:mediationverse")
```

## Phase 7: Git Status Review

### Check Repository Status
```bash
# Review what's changed
git status
git diff

# Check for untracked files that should be added
git ls-files --others --exclude-standard
```

### Verify .gitignore
```bash
# Shouldn't see these in git status:
# - .Rproj.user/
# - .Rhistory
# - .RData
# - *.Rcheck/
# - *.tar.gz (except in specific locations)
```

## Phase 8: Pre-Commit Checklist

Go through this checklist before committing:

**Code Quality**:
- [ ] All R code follows tidyverse style guide
- [ ] No linter errors or warnings
- [ ] Spelling checked
- [ ] No commented-out code blocks

**Documentation**:
- [ ] All exports documented with roxygen2
- [ ] Examples work and are meaningful
- [ ] NEWS.md updated (if applicable)
- [ ] README.md updated (if changed)

**Testing**:
- [ ] All tests pass
- [ ] Coverage >80%
- [ ] New functionality has tests
- [ ] Edge cases covered

**Package Check**:
- [ ] `R CMD check` passes with 0 errors, 0 warnings
- [ ] Good practices check reviewed
- [ ] Dependencies are minimal and necessary

**Statistical Correctness**:
- [ ] Formulas verified against literature
- [ ] Identification assumptions documented
- [ ] Inference methods appropriate
- [ ] Results match expectations on test data

**Git**:
- [ ] Only relevant files staged
- [ ] Sensitive data not included
- [ ] Commit message is descriptive

## Phase 9: Commit

If all checks pass, create a descriptive commit:

```bash
# Stage changes
git add -p  # Review each change

# Commit with detailed message
git commit -m "feat: Add multiply robust mediation estimator

- Implement doubly robust outcome regression
- Add inverse probability weighting
- Include bootstrap and delta method inference  
- Add comprehensive tests (100% coverage)
- Update vignette with new example

Closes #42"
```

## Phase 10: Post-Commit Actions

### Update Documentation Site
```r
# Rebuild and deploy pkgdown site
pkgdown::build_site()
```

### Create Pull Request (if applicable)
```bash
# Push to remote
git push origin feature/multiply-robust

# Create PR via gh CLI
gh pr create \
  --title "Add multiply robust mediation estimator" \
  --body "Implements doubly robust estimation for mediation analysis. See #42 for details."
```

## Quick Check Commands

For rapid iteration, use these shortcuts:

```bash
# Minimal check (fast)
R -e "devtools::load_all(); devtools::test(); devtools::check_man()"

# Standard check (medium)
R -e "devtools::test(); devtools::check()"

# Full check (slow but thorough)
R -e "styler::style_pkg(); devtools::test(); covr::report(); devtools::check(); goodpractice::gp()"
```

## Troubleshooting Common Issues

### Tests Fail
1. Run individual test file: `testthat::test_file("tests/testthat/test-X.R")`
2. Debug with `browser()` in test
3. Check for changed behavior vs. changed test expectations

### Documentation Issues
1. Rebuild: `devtools::document()`
2. Check for roxygen2 syntax errors
3. Verify `@export` tags present

### R CMD Check Warnings
1. Read the warning carefully
2. Search R-package-devel mailing list
3. Check CRAN policies documentation
4. Ask in #r-package-devel if stuck

## Success Criteria

This check is complete when:
- ✓ No R CMD check errors or warnings
- ✓ All tests pass with >80% coverage
- ✓ Documentation complete and builds
- ✓ Code follows style guide
- ✓ Commit message is descriptive
- ✓ Changes are staged and committed

Run this command before every commit to maintain high code quality!
