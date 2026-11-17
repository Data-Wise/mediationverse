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

test_that("find_conflicts() is quiet and returns an empty frame for < 2 packages", {
  expect_silent(res <- mediationverse:::find_conflicts("medfit"))
  expect_s3_class(res, "data.frame")
  expect_false(inherits(res, "mediationverse_conflicts"))
  expect_named(res, c("function_name", "packages", "winner"))
  expect_equal(nrow(res), 0L)
  expect_silent(mediationverse:::find_conflicts(character(0)))
})

test_that("find_conflicts() reports a shared export without printing anything", {
  testthat::local_mocked_bindings(
    getNamespaceExports = function(ns) {
      switch(ns,
        medfit  = c("extract_mediation", "only_in_medfit"),
        probmed = c("extract_mediation", "pmed")
      )
    },
    .package = "base"
  )

  expect_silent(res <- mediationverse:::find_conflicts(c("medfit", "probmed")))
  expect_equal(res$function_name, "extract_mediation")
  expect_equal(res$packages, "medfit, probmed")
  expect_true(res$winner %in% c("medfit", "probmed"))
})

test_that("find_conflicts() returns an empty frame when exports do not overlap", {
  testthat::local_mocked_bindings(
    getNamespaceExports = function(ns) {
      switch(ns, medfit = "a", probmed = "b")
    },
    .package = "base"
  )

  res <- mediationverse:::find_conflicts(c("medfit", "probmed"))
  expect_equal(nrow(res), 0L)
})

test_that("find_conflicts() ignores S4 method-table internals", {
  testthat::local_mocked_bindings(
    getNamespaceExports = function(ns) {
      switch(ns,
        medfit  = c(".__T__[:base", ".__C__Foo", "only_medfit"),
        probmed = c(".__T__[:base", ".__C__Foo", "only_probmed")
      )
    },
    .package = "base"
  )

  res <- mediationverse:::find_conflicts(c("medfit", "probmed"))

  expect_equal(nrow(res), 0L)
})

test_that("find_conflicts() records packages whose export lookup failed", {
  testthat::local_mocked_bindings(
    getNamespaceExports = function(ns) {
      if (identical(ns, "probmed")) stop("no such namespace")
      "extract_mediation"
    },
    .package = "base"
  )

  res <- mediationverse:::find_conflicts(c("medfit", "probmed", "medsim"))

  expect_identical(attr(res, "failed_lookup"), "probmed")
  # medfit and medsim still conflict on the shared export.
  expect_equal(res$function_name, "extract_mediation")
})

test_that("find_conflicts() reports no failed lookups on a clean run", {
  testthat::local_mocked_bindings(
    getNamespaceExports = function(ns) switch(ns, medfit = "a", probmed = "b"),
    .package = "base"
  )

  res <- mediationverse:::find_conflicts(c("medfit", "probmed"))

  expect_identical(attr(res, "failed_lookup"), character(0))
})

test_that("mediationverse_conflicts() does not expose failed_lookup", {
  testthat::local_mocked_bindings(
    getNamespaceExports = function(ns) {
      if (identical(ns, "probmed")) stop("boom")
      "extract_mediation"
    },
    .package = "base"
  )
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) TRUE,
    .package = "base"
  )

  res <- suppressMessages(mediationverse_conflicts(only_loaded = FALSE))

  expect_null(attr(res, "failed_lookup"))
})

# Run mediationverse_conflicts(), capturing cli/plain messages.
run_conflicts <- function(...) {
  msgs <- character()
  res <- withCallingHandlers(
    mediationverse_conflicts(...),
    message = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )
  list(res = res, msgs = msgs)
}

test_that("mediationverse_conflicts() warns instead of claiming success when a lookup failed", {
  # Every package but probmed exports a distinct name, and probmed's lookup
  # errors: no conflicts remain, but the inspection was incomplete.
  testthat::local_mocked_bindings(
    getNamespaceExports = function(ns) {
      if (identical(ns, "probmed")) stop("boom")
      paste0("only_", ns)
    },
    requireNamespace = function(package, ...) TRUE,
    .package = "base"
  )

  r <- run_conflicts(only_loaded = FALSE)

  expect_equal(nrow(r$res), 0L)
  expect_null(attr(r$res, "failed_lookup"))
  expect_true(any(grepl("Could not inspect probmed", r$msgs)))
  expect_false(any(grepl("No conflicts found among", r$msgs)))
})

test_that("mediationverse_conflicts() warns about failed lookups even when conflicts exist", {
  testthat::local_mocked_bindings(
    getNamespaceExports = function(ns) {
      if (identical(ns, "probmed")) stop("boom")
      "extract_mediation"
    },
    requireNamespace = function(package, ...) TRUE,
    .package = "base"
  )

  r <- run_conflicts(only_loaded = FALSE)

  expect_s3_class(r$res, "mediationverse_conflicts")
  expect_true(any(grepl("Could not inspect probmed", r$msgs)))
})

test_that("mediationverse_conflicts() still reports a clean run as clean", {
  testthat::local_mocked_bindings(
    getNamespaceExports = function(ns) paste0("only_", ns),
    requireNamespace = function(package, ...) TRUE,
    .package = "base"
  )

  r <- run_conflicts(only_loaded = FALSE)

  expect_equal(nrow(r$res), 0L)
  expect_true(any(grepl("No conflicts found among", r$msgs)))
  expect_false(any(grepl("Could not read", r$msgs)))
})

test_that("mediationverse_conflicts() warns when an installed member cannot be loaded", {
  # medfit is on disk but fails to load; the other two load and do not conflict.
  testthat::local_mocked_bindings(
    pkg_installed = function(pkg) pkg %in% c("probmed", "medsim"),
    pkg_on_disk = function(pkg) pkg %in% c("medfit", "probmed", "medsim")
  )
  testthat::local_mocked_bindings(
    getNamespaceExports = function(ns) paste0("only_", ns),
    .package = "base"
  )

  r <- run_conflicts(only_loaded = FALSE)

  expect_equal(nrow(r$res), 0L)
  expect_true(any(grepl("Could not inspect medfit", r$msgs)))
  expect_false(any(grepl("No conflicts found among", r$msgs)))
})

test_that("mediationverse_conflicts() warns about an unloadable member even with < 2 loadable", {
  testthat::local_mocked_bindings(
    pkg_installed = function(pkg) identical(pkg, "probmed"),
    pkg_on_disk = function(pkg) pkg %in% c("medfit", "probmed")
  )

  r <- run_conflicts(only_loaded = FALSE)

  expect_equal(nrow(r$res), 0L)
  expect_true(any(grepl("Could not inspect medfit", r$msgs)))
})

test_that("an absent member is not reported as uninspected by mediationverse_conflicts()", {
  testthat::local_mocked_bindings(
    pkg_installed = function(pkg) pkg %in% c("probmed", "medsim"),
    pkg_on_disk = function(pkg) pkg %in% c("probmed", "medsim")
  )
  testthat::local_mocked_bindings(
    getNamespaceExports = function(ns) paste0("only_", ns),
    .package = "base"
  )

  r <- run_conflicts(only_loaded = FALSE)

  expect_false(any(grepl("Could not inspect", r$msgs)))
  expect_true(any(grepl("No conflicts found among", r$msgs)))
})
