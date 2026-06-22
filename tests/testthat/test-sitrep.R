test_that("mediationverse_sitrep() returns invisible data frame with expected structure", {
  result <- mediationverse_sitrep()

  expect_s3_class(result, "data.frame")
  expect_named(result, c("package", "installed", "version", "source"))
  expect_type(result$package, "character")
  expect_type(result$installed, "logical")
  expect_type(result$version, "character")
  expect_type(result$source, "character")
})

test_that("mediationverse_sitrep() covers exactly the 5 core packages", {
  result <- mediationverse_sitrep()
  expect_setequal(
    result$package,
    c("medfit", "probmed", "RMediation", "medrobust", "medsim")
  )
  expect_equal(nrow(result), 5L)
})

test_that("mediationverse_sitrep() source column is 'CRAN' or 'GitHub' only", {
  result <- mediationverse_sitrep()
  expect_true(all(result$source %in% c("CRAN", "GitHub")))
})

test_that("mediationverse_sitrep() only RMediation is CRAN; medfit + others are GitHub", {
  # medfit 0.3.x is GitHub-only; CRAN has 0.2.1 which is too old for the ecosystem
  result <- mediationverse_sitrep()
  cran_pkgs   <- result$package[result$source == "CRAN"]
  github_pkgs <- result$package[result$source == "GitHub"]
  expect_setequal(cran_pkgs, "RMediation")
  expect_setequal(github_pkgs, c("medfit", "probmed", "medrobust", "medsim"))
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
  expect_true(any(grepl("CRAN status:", out)))
  # Structure of the returned data frame is unchanged in the fallback path.
  expect_s3_class(result, "data.frame")
  expect_named(result, c("package", "installed", "version", "source"))
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
