Debug and fix issue: $ARGUMENTS

## Phase 1: Investigation
1. **Understand the problem**:
   - Read any error messages or bug reports carefully
   - Identify which function(s) are affected
   - Note any specific conditions that trigger the issue

2. **Reproduce the issue**:
   - Create minimal reproducible example
   - Run the failing code
   - Capture exact error message
   - Note R version, package versions with `sessionInfo()`

3. **Locate the source**:
   - Use `traceback()` output if available
   - Review relevant function code
   - Check recent git commits: `git log --oneline -10 path/to/file.R`
   - Look for related issues: `gh issue list --search "$ARGUMENTS"`

**STOP and show me your findings before proceeding**

## Phase 2: Diagnosis
1. **Identify root cause**:
   - Is it a statistical issue (wrong formula, incorrect calculation)?
   - Is it a coding issue (indexing error, type mismatch)?
   - Is it an edge case (missing data, zero variance)?
   - Is it a breaking change in a dependency?

2. **Check for side effects**:
   - Will fixing this break other functionality?
   - Are there related functions that might have the same issue?
   - Review test suite for similar patterns

3. **Propose solution**:
   - Describe the fix approach
   - Explain why this solves the problem
   - Note any trade-offs or implications

**STOP and confirm the solution approach before implementing**

## Phase 3: Fix Implementation
1. **Write a failing test FIRST**:
   - Create test that reproduces the bug
   - Run `devtools::test()` to confirm it fails
   - Commit the test: `git add tests/; git commit -m "test: Add failing test for #ISSUE"`

2. **Implement the fix**:
   - Make minimal changes to fix the issue
   - Add comments explaining non-obvious changes
   - Maintain code style consistency

3. **Verify the fix**:
   - Run the new test: `testthat::test_file("tests/testthat/test-*.R")`
   - Confirm it now passes
   - Run full test suite: `devtools::test()`
   - Ensure no regressions

## Phase 4: Validation
1. **Extended testing**:
   - Test edge cases related to the fix
   - Run `devtools::check()` for full validation
   - Check that examples still work: `devtools::run_examples()`
   - Verify documentation is still accurate

2. **Performance check** (if relevant):
   - Compare performance before/after with `bench::mark()`
   - Ensure fix doesn't significantly slow things down

3. **Manual testing**:
   - Run the original failing example
   - Test with different data scenarios
   - Verify output is now correct

## Phase 5: Documentation
1. **Update NEWS.md**:
   ```
   # mediationverse (development version)
   
   ## Bug fixes
   
   * Fixed issue where `function_name()` would fail with X condition (#ISSUE)
   ```

2. **Update function documentation** if behavior changed:
   - Clarify any edge case handling
   - Add note to @details if important
   - Update examples if needed

3. **Consider vignette update** if this affects user-facing behavior

## Phase 6: Finalization
1. **Create descriptive commit**:
   ```
   fix: Correct bootstrap CI calculation in mediate()
   
   - Fixed bug where percentile CIs were incorrectly computed
   - Added validation for bootstrap sample size
   - Improved error message for singular covariance matrices
   - Added tests for edge cases
   
   Fixes #42
   ```

2. **Optional: Create pull request**:
   - Push to branch: `git push origin fix/issue-$ARGUMENTS`
   - Create PR: `gh pr create --title "Fix: ..." --body "Closes #..."`

3. **Update any related documentation**:
   - Rebuild pkgdown site if needed: `pkgdown::build_site()`
   - Check that fix is reflected in documentation

## Debugging Tools
Use these R commands during investigation:

```r
# Set breakpoint in function
debugonce(mediationverse::mediate)

# Trace function calls
trace(mediationverse::mediate, tracer = browser)

# Check object structure
str(result)
class(result)

# Validate S7 object
S7::validate(result)

# Find where function is defined
body(mediationverse::mediate)
args(mediationverse::mediate)
```

## Common Bug Patterns in Mediation Analysis

**Statistical Issues**:
- Incorrect effect decomposition (TE ≠ NDE + NIE)
- Wrong standard error formula
- Bootstrap sampling without replacement
- Mediator and outcome models using inconsistent data

**Coding Issues**:
- Off-by-one errors in indexing
- Matrix dimension mismatches
- Factor/character confusion
- Missing value propagation
- Singular matrix in variance calculation

**Edge Cases**:
- Zero variance in treatment/mediator
- All observations in one treatment group
- NA values not handled properly
- Intercept-only models
- Non-positive-definite covariance matrices

## Quality Checklist
Before marking this complete:
- [ ] Bug is fully reproduced
- [ ] Root cause identified
- [ ] Failing test created and committed
- [ ] Fix implemented with minimal changes
- [ ] New test passes
- [ ] All existing tests still pass
- [ ] R CMD check passes
- [ ] NEWS.md updated
- [ ] Commit message is descriptive
- [ ] Related issue closed (if applicable)
