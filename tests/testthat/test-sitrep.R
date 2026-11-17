test_that("mediationverse_sitrep() returns invisible data frame with expected structure", {
  result <- mediationverse_sitrep()

  expect_s3_class(result, "data.frame")
  expect_named(result, c("package", "installed", "version", "source", "installed_from"))
  expect_type(result$package, "character")
  expect_type(result$installed, "logical")
  expect_type(result$version, "character")
  expect_type(result$source, "character")
})

test_that("mediationverse_sitrep() covers exactly the 6 core packages", {
  result <- mediationverse_sitrep()
  expect_setequal(
    result$package,
    c("medfit", "probmed", "RMediation", "medrobust", "medsim", "missingmed")
  )
  expect_equal(nrow(result), 6L)
})

test_that("mediationverse_sitrep() source column is 'CRAN' or 'GitHub' only", {
  result <- mediationverse_sitrep()
  expect_true(all(result$source %in% c("CRAN", "GitHub")))
})

test_that("mediationverse_sitrep() only RMediation is CRAN; medfit + others are GitHub", {
  # medfit is sourced from GitHub: CRAN 0.3.2 predates two result-changing fixes in 0.5.0
  result <- mediationverse_sitrep()
  cran_pkgs   <- result$package[result$source == "CRAN"]
  github_pkgs <- result$package[result$source == "GitHub"]
  expect_setequal(cran_pkgs, "RMediation")
  expect_setequal(github_pkgs, c("medfit", "probmed", "medrobust", "medsim", "missingmed"))
})

test_that("mediationverse_sitrep() returns invisibly and prints without error", {
  expect_invisible(mediationverse_sitrep())
  expect_no_error(mediationverse_sitrep())
})

test_that("mediationverse_sitrep() falls back to plain cat without cli", {
  skip_if_not_installed("cli")
  real_require <- base::requireNamespace  # capture before mocking to avoid recursion
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "cli")) FALSE else real_require(package, ...)
    },
    .package = "base"
  )

  out <- capture.output(result <- mediationverse_sitrep())
  expect_true(any(grepl("mediationverse situation report", out)))
  expect_true(any(grepl("Core packages:", out)))
  expect_true(any(grepl("Install sources:", out)))
  # Structure of the returned data frame is unchanged in the fallback path.
  expect_s3_class(result, "data.frame")
  expect_named(result, c("package", "installed", "version", "source", "installed_from"))
})

test_that("mediationverse_sitrep() prints an install hint for a missing core package", {
  skip_if_not_installed("cli")
  # Keep cli so the cli branch runs, but force every core package to look
  # uninstalled so the per-package "not installed" + install-hint branch fires.
  real_require <- base::requireNamespace  # capture before mocking to avoid recursion
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "cli")) real_require(package, ...) else FALSE
    },
    .package = "base"
  )

  expect_no_error(result <- mediationverse_sitrep())
  expect_true(all(!result$installed))
  expect_true(all(is.na(result$version)))
})

test_that("mediationverse_sitrep() labels the source as recommended, not detected", {
  skip_if_not_installed("cli")
  real_require <- base::requireNamespace
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "cli")) FALSE else real_require(package, ...)
    },
    .package = "base"
  )

  out <- capture.output(mediationverse_sitrep())
  expect_true(any(grepl("[recommended: CRAN]", out, fixed = TRUE)))
  expect_true(any(grepl("[recommended: GitHub]", out, fixed = TRUE)))
})

test_that("sitrep() reports the detected install source and flags a mismatch", {
  # "stats" is always installed; pretend it is a CRAN-recommended member that
  # was installed from GitHub.
  real_require <- base::requireNamespace
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "cli")) FALSE else real_require(package, ...)
    },
    .package = "base"
  )
  testthat::local_mocked_bindings(
    mv_core_packages = function() "stats",
    mv_source = function(pkg) "CRAN",
    pkg_provenance = function(pkg) "GitHub"
  )

  out <- capture.output(result <- mediationverse_sitrep())
  expect_identical(result$installed_from, "GitHub")
  expect_true(any(grepl("(from GitHub) [recommended: CRAN]", out, fixed = TRUE)))
  expect_true(any(grepl("stats installed from GitHub; recommended: CRAN", out, fixed = TRUE)))
})

test_that("sitrep() has NA installed_from for packages that are not installed", {
  skip_if_not_installed("cli")
  real_require <- base::requireNamespace
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "cli")) real_require(package, ...) else FALSE
    },
    .package = "base"
  )
  result <- mediationverse_sitrep()
  expect_true(all(is.na(result$installed_from)))
})

test_that("from_text() and source_matches() cover the provenance labels", {
  expect_identical(mediationverse:::from_text(NA_character_), "unknown origin")
  expect_identical(mediationverse:::from_text("CRAN"), "from CRAN")
  expect_true(mediationverse:::source_matches("local", "CRAN"))
  expect_true(mediationverse:::source_matches("base", "GitHub"))
  expect_true(mediationverse:::source_matches("CRAN", "CRAN"))
  expect_false(mediationverse:::source_matches("GitHub", "CRAN"))
  expect_true(mediationverse:::source_matches("r-universe", "GitHub"))
  expect_false(mediationverse:::source_matches("CRAN", "GitHub"))
  expect_false(mediationverse:::source_matches("other", "GitHub"))
})
