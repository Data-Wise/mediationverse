Migrate to S7: $ARGUMENTS

This command helps migrate S3 or S4 classes/methods to the modern S7 object system.

## Phase 1: Analysis (DO NOT MODIFY CODE YET)
1. **Identify current implementation**:
   - Find all S3/S4 class definitions for $ARGUMENTS
   - List all methods defined (print, summary, plot, coef, etc.)
   - Identify all places where the class is instantiated
   - Search for any inheritance relationships
   - Find all accessor functions (getters/setters)

2. **Document current behavior**:
   - What slots/attributes exist?
   - What are their types and constraints?
   - What validation logic exists (if any)?
   - What does each method do?
   - Are there any implicit assumptions or constraints?

3. **Create migration plan**:
   - Map S3 attributes / S4 slots to S7 properties
   - Design S7 class structure
   - Plan validator function logic
   - List all methods that need conversion
   - Identify breaking changes (if any)

**STOP and show me the plan before proceeding**

## Phase 2: Write Tests for Current Behavior
**This is CRITICAL - we must preserve existing functionality**

1. **Create comprehensive tests** in `tests/testthat/test-$ARGUMENTS-s7.R`:
   ```r
   test_that("$ARGUMENTS preserves S3/S4 behavior after S7 migration", {
     # Test object creation
     obj <- create_$ARGUMENTS_object()
     
     # Test all properties are correct
     expect_true(is.finite(obj$property1))
     
     # Test all methods work
     expect_output(print(obj))
     expect_no_error(summary(obj))
     
     # Test edge cases
     expect_error(create_$ARGUMENTS_object(bad_input))
   })
   ```

2. **Test EVERY method**:
   - print
   - summary  
   - plot (if exists)
   - coef, vcov, confint (if applicable)
   - Custom accessors
   - Subsetting behavior

3. **Run tests to establish baseline**:
   ```r
   devtools::test_active_file()
   # ALL TESTS MUST PASS before migration
   ```

4. **Commit tests**:
   ```
   git add tests/testthat/test-$ARGUMENTS-s7.R
   git commit -m "test: Add comprehensive tests before S7 migration of $ARGUMENTS"
   ```

## Phase 3: Create S7 Class Definition

1. **Define S7 class** in `R/$ARGUMENTS-class.R`:
   ```r
   #' @title $ARGUMENTS S7 Class
   #' @description [Description of what this class represents]
   #' @export
   $ARGUMENTS <- new_class(
     name = "$ARGUMENTS",
     properties = list(
       # Map each S3 attribute / S4 slot to S7 property
       property1 = class_double,
       property2 = class_character,
       property3 = new_property(
         class = class_list,
         default = list()
       )
     ),
     validator = function(self) {
       # CRITICAL: Add all validation logic
       
       # Check for required properties
       if (length(self@property1) == 0) {
         return("property1 cannot be empty")
       }
       
       # Validate ranges/constraints
       if (any(self@property1 < 0)) {
         return("property1 must be non-negative")
       }
       
       # Check consistency between properties
       if (length(self@property1) != length(self@property2)) {
         return("property1 and property2 must have same length")
       }
       
       # Validate statistical properties
       if (!all(is.finite(self@property1))) {
         return("property1 must be finite")
       }
     }
   )
   ```

2. **Create constructor helper**:
   ```r
   #' @export
   new_$ARGUMENTS <- function(property1, property2, property3 = list()) {
     $ARGUMENTS(
       property1 = property1,
       property2 = property2,
       property3 = property3
     )
   }
   ```

## Phase 4: Migrate Methods

1. **Convert each method to S7**:
   
   **S3 style (OLD)**:
   ```r
   print.$ARGUMENTS <- function(x, ...) {
     cat("Object of class", class(x), "\n")
     cat("Property1:", x$property1, "\n")
   }
   ```
   
   **S7 style (NEW)**:
   ```r
   method(print, $ARGUMENTS) <- function(x, ...) {
     cat("Object of class", class(x)[[1]], "\n")
     cat("Property1:", x@property1, "\n")
   }
   ```

2. **Update all methods**:
   - Replace `x$property` with `x@property` (S7 accessor)
   - Replace `attr(x, "name")` with `x@name`
   - Update class checks: `inherits(x, "$ARGUMENTS")` → `S7_inherits(x, $ARGUMENTS)`
   - Register each method with `method(generic, $ARGUMENTS) <- function(...)`

3. **Common method templates**:
   
   ```r
   # Print method
   method(print, $ARGUMENTS) <- function(x, digits = 3, ...) {
     cat("\n$ARGUMENTS Object\n")
     cat(rep("=", 50), "\n\n", sep = "")
     cat("Property1:", format(x@property1, digits = digits), "\n")
     invisible(x)
   }
   
   # Summary method  
   method(summary, $ARGUMENTS) <- function(object, ...) {
     structure(
       list(
         property1 = summary(object@property1),
         property2 = object@property2
       ),
       class = "summary.$ARGUMENTS"
     )
   }
   ```

## Phase 5: Update NAMESPACE and Exports

1. **Document class and methods**:
   ```r
   #' @exportClass $ARGUMENTS
   #' @export
   ```

2. **Ensure all generics are available**:
   - Import from S7: `@importFrom S7 new_class new_property method`
   - Import generics if needed: `@importFrom stats coef vcov`

3. **Update documentation**:
   ```r
   devtools::document()
   ```

## Phase 6: Find and Update All Usage

1. **Search for object instantiation**:
   ```bash
   # Find all places creating old S3/S4 objects
   grep -r "structure.*class.*$ARGUMENTS" R/
   grep -r "new(\"$ARGUMENTS\"" R/
   ```

2. **Update to S7 constructor**:
   ```r
   # OLD S3
   result <- structure(
     list(property1 = x, property2 = y),
     class = "$ARGUMENTS"
   )
   
   # NEW S7
   result <- $ARGUMENTS(
     property1 = x,
     property2 = y
   )
   ```

3. **Update accessor usage**:
   ```r
   # OLD
   x$property1
   attr(x, "property1")
   
   # NEW  
   x@property1
   ```

## Phase 7: Testing and Validation

1. **Run test suite**:
   ```r
   devtools::test()
   # ALL tests from Phase 2 must still pass!
   ```

2. **Fix any test failures**:
   - Update test expectations if behavior intentionally changed
   - Fix bugs if behavior unintentionally changed
   - Add new tests for S7-specific features

3. **Run comprehensive checks**:
   ```r
   devtools::check()
   ```

4. **Test with examples**:
   ```r
   devtools::run_examples()
   ```

## Phase 8: Documentation Updates

1. **Update class documentation**:
   - Explain this is now an S7 class
   - Document all properties (were slots/attributes)
   - Show example of creating objects
   - Document available methods

2. **Update function documentation**:
   - Update @return to mention S7 class
   - Update examples to use new accessor syntax
   - Note any breaking changes in @details

3. **Update vignettes**:
   - Search for examples using old syntax
   - Update to S7 accessors (`x@property` vs `x$property`)
   - Add note about S7 migration if relevant

4. **Update NEWS.md**:
   ```
   # mediationverse (development version)
   
   ## Breaking changes
   
   * `$ARGUMENTS` migrated from S3/S4 to S7 class system. 
     Users should now use `@` accessor (e.g., `obj@property`) 
     instead of `$` (e.g., `obj$property`). All methods preserved.
   ```

## Phase 9: Deprecation Strategy (Optional)

If you want to provide backward compatibility:

1. **Add S3 compatibility layer**:
   ```r
   #' @export
   `$.$ARGUMENTS` <- function(x, name) {
     .Deprecated(
       msg = "Use @ accessor instead of $ for S7 objects"
     )
     slot(x, name)
   }
   ```

2. **Provide migration helper**:
   ```r
   #' @export
   as_s7_$ARGUMENTS <- function(old_obj) {
     $ARGUMENTS(
       property1 = old_obj$property1,
       property2 = old_obj$property2
     )
   }
   ```

## Phase 10: Finalization

1. **Final verification**:
   - All tests pass: `devtools::test()`
   - R CMD check clean: `devtools::check()`
   - Examples work: `devtools::run_examples()`
   - Coverage maintained: `covr::package_coverage()`
   - Documentation builds: `pkgdown::build_site()`

2. **Create comprehensive commit**:
   ```
   refactor: Migrate $ARGUMENTS from S3/S4 to S7
   
   - Convert $ARGUMENTS class to S7 object system
   - Add comprehensive validator for all properties
   - Migrate all methods (print, summary, coef, etc.)
   - Update all usage throughout package
   - Add extensive tests to ensure behavior preserved
   - Update documentation and vignettes
   
   BREAKING CHANGE: Users must now use @ accessor instead of $
   for S7 properties (e.g., obj@property instead of obj$property)
   
   Closes #ISSUE
   ```

3. **Consider creating migration guide**:
   - Document in vignette or article
   - Show side-by-side old vs new syntax
   - Provide migration examples

## S7 Best Practices Checklist

- [ ] Class has comprehensive validator
- [ ] All properties have explicit class definitions
- [ ] Validator checks all constraints
- [ ] All S3/S4 methods converted to S7 methods
- [ ] Tests verify behavior preserved
- [ ] Documentation updated with S7 syntax
- [ ] NAMESPACE includes S7 imports
- [ ] Examples use @ accessor, not $
- [ ] NEWS.md documents breaking changes
- [ ] All usage in package updated
- [ ] R CMD check passes

## Common S7 Migration Issues

**Property access**: Remember `@` not `$` for S7 objects
**Class checking**: Use `S7_inherits()` or `inherits()`, not `class() ==`
**Validation**: S7 validators run automatically on object creation
**Methods**: Must explicitly register with `method(generic, class)`
**Documentation**: Must export class with `@exportClass`

## Resources
- [S7 Documentation](https://rconsortium.github.io/S7/)
- [S7 Design Principles](https://rconsortium.github.io/S7/articles/S7.html)
- [Migration from S3](https://rconsortium.github.io/S7/articles/migration.html)
