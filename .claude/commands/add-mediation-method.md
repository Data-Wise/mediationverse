Please implement a new mediation method: $ARGUMENTS

Follow this workflow:

## Phase 1: Planning (DO NOT CODE YET)
1. Read the CLAUDE.md file for package standards
2. Review existing mediation methods in R/ directory to understand current patterns
3. Create a detailed plan covering:
   - S7 class structure for results
   - Required statistical assumptions
   - Parameter validation approach
   - Estimation procedure steps
   - Standard error calculation method (bootstrap/delta method)
   - Edge cases to handle

**STOP and show me the plan before proceeding**

## Phase 2: Implementation (After plan approval)
1. Create R/$ARGUMENTS.R with:
   - Complete roxygen2 documentation header
   - Input validation at function start
   - S7 class definition with validator
   - Main estimation function
   - Print/summary methods
   
2. Follow these coding standards:
   - Use :: notation for all external functions
   - Clear variable names (no single letters except i, j for indices)
   - Include inline comments for complex statistical operations
   - Vectorized operations (no loops unless necessary)
   - Error messages that guide users

## Phase 3: Testing (Test-Driven Development)
1. Create tests/testthat/test-$ARGUMENTS.R with:
   - Tests for correct output structure (expect_s7_class)
   - Tests for edge cases:
     * Missing data (NA values)
     * Zero variance
     * Single observation
     * Perfect collinearity
   - Tests for error handling
   - Comparison with known results (if available)
   
2. Run tests: `devtools::test_active_file()`
3. Iterate until all tests pass

## Phase 4: Documentation
1. Add example in function documentation:
   - Simulate realistic data
   - Show typical usage
   - Demonstrate result interpretation
   
2. Consider if vignette update needed

3. Add function to pkgdown reference in _pkgdown.yml

## Phase 5: Verification
1. Run full check: `devtools::check()`
2. Check code style: `styler::style_file("R/$ARGUMENTS.R")`
3. Run linter: `lintr::lint("R/$ARGUMENTS.R")`
4. Verify examples run: `devtools::run_examples()`
5. Check test coverage: `covr::file_coverage("R/$ARGUMENTS.R")`

## Phase 6: Integration
1. Update NAMESPACE: `devtools::document()`
2. Rebuild documentation: `pkgdown::build_reference()`
3. Create commit with descriptive message
4. Suggest creating GitHub issue if this addresses a feature request

## Key Statistical Requirements
- Document all identification assumptions
- Use VanderWeele (2015) notation for effect measures
- Provide both point estimates and uncertainty quantification
- Include sensitivity analysis considerations if relevant
- Cite relevant methodological papers

## Quality Checks
Before considering this complete:
- [ ] All tests pass
- [ ] Test coverage >80% for new code
- [ ] R CMD check passes with no errors/warnings
- [ ] Documentation includes working example
- [ ] Code follows tidyverse style guide
- [ ] Function handles edge cases gracefully
- [ ] Error messages are informative
