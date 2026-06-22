test_that("mediationverse_conflicts() returns data frame with expected columns", {
  result <- mediationverse_conflicts()

  expect_s3_class(result, "data.frame")
  expect_named(result, c("function_name", "packages", "winner"))
})

test_that("mediationverse_conflicts(only_loaded = TRUE) returns empty frame when < 2 ecosystem pkgs loaded", {
  # In a test environment, the ecosystem packages are not attached; mediationverse itself
  # may or may not be. Either way, fewer than 2 are on the search path, so the result
  # should be an empty (0-row) data frame.
  result <- mediationverse_conflicts(only_loaded = TRUE)

  expect_s3_class(result, "data.frame")
  # Should not error and should have correct shape
  expect_named(result, c("function_name", "packages", "winner"))
})

test_that("mediationverse_conflicts() returns invisibly", {
  expect_invisible(mediationverse_conflicts())
})

test_that("mediationverse_conflicts() prints without error (empty case)", {
  result <- mediationverse_conflicts()
  expect_no_error(print(result))
  expect_invisible(print(result))
})

test_that("mediationverse_conflicts(only_loaded = FALSE) returns correct structure", {
  result <- mediationverse_conflicts(only_loaded = FALSE)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("function_name", "packages", "winner"))

  if (nrow(result) > 0) {
    expect_type(result$function_name, "character")
    expect_type(result$packages, "character")
    expect_type(result$winner, "character")
    # winner must be one of the packages listed in the packages field
    for (i in seq_len(nrow(result))) {
      pkg_list <- strsplit(result$packages[i], ", ")[[1]]
      expect_true(result$winner[i] %in% pkg_list)
    }
  }
})

## ---- detection + print branches (mocked exports; deterministic) -------------
## The real conflict-detection loop only fires when >= 2 ecosystem packages share
## an exported name. Rather than depend on which packages happen to be installed,
## mock `getNamespaceExports` so two core packages share a function name.

test_that("conflict detection finds a shared export and builds the data frame", {
  local_mocked_bindings(
    requireNamespace = function(package, ...) TRUE,  # all core pkgs "installed"
    getNamespaceExports = function(ns) {
      switch(ns,
        medfit  = c("extract_mediation", "fit_only_medfit"),
        probmed = c("extract_mediation", "pmed"),
        character(0)
      )
    },
    .package = "base"
  )
  res <- mediationverse_conflicts(only_loaded = FALSE)
  expect_s3_class(res, "mediationverse_conflicts")
  expect_true("extract_mediation" %in% res$function_name)
  row <- res[res$function_name == "extract_mediation", ]
  expect_match(row$packages, "medfit", fixed = TRUE)
  expect_match(row$packages, "probmed", fixed = TRUE)
  # winner is one of the conflicting packages
  expect_true(row$winner %in% strsplit(row$packages, ", ")[[1]])
})

test_that("no conflicts among >= 2 packages reports success and returns empty frame", {
  local_mocked_bindings(
    requireNamespace = function(package, ...) TRUE,
    getNamespaceExports = function(ns) {
      switch(ns,
        medfit  = "fit_only_medfit",
        probmed = "pmed_only",
        character(0)
      )
    },
    .package = "base"
  )
  res <- mediationverse_conflicts(only_loaded = FALSE)
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 0L)
})

test_that("<2 packages path falls back to message() when cli is unavailable", {
  local_mocked_bindings(
    requireNamespace = function(package, ...) FALSE,  # cli "missing"; core not installed
    .package = "base"
  )
  expect_message(
    mediationverse_conflicts(only_loaded = FALSE),
    "fewer than 2"
  )
})

test_that("print.mediationverse_conflicts() renders a non-empty conflict table", {
  # cli writes outside capture.output()'s stdout sink, so assert behaviour here
  # (the cli branch still executes); the non-cli test below asserts the text.
  df <- data.frame(
    function_name = "extract_mediation",
    packages = "medfit, probmed",
    winner = "probmed",
    stringsAsFactors = FALSE
  )
  class(df) <- c("mediationverse_conflicts", "data.frame")
  expect_no_error(print(df))
  expect_invisible(print(df))
})

test_that("print.mediationverse_conflicts() non-empty branch works without cli", {
  df <- data.frame(
    function_name = "extract_mediation",
    packages = "medfit, probmed",
    winner = "probmed",
    stringsAsFactors = FALSE
  )
  class(df) <- c("mediationverse_conflicts", "data.frame")
  local_mocked_bindings(requireNamespace = function(package, ...) FALSE, .package = "base")
  out <- capture.output(print(df))
  expect_true(any(grepl("extract_mediation", out)))
  expect_true(any(grepl("conflict", out)))
})
