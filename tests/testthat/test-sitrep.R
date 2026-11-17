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

# Plain-text path with a fixed set of "installed" members, so output is checkable.
# `members`: named list(package = list(version, source, latest)).
mock_updates_env <- function(members, env = parent.frame()) {
  real_require <- base::requireNamespace
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "cli")) FALSE else real_require(package, ...)
    },
    .package = "base",
    .env = env
  )
  testthat::local_mocked_bindings(
    mv_core_packages = function() names(members),
    mv_source = function(pkg) members[[pkg]]$source,
    pkg_version = function(pkg) members[[pkg]]$version,
    pkg_provenance = function(pkg) "GitHub",
    pkg_latest = function(pkg, source) members[[pkg]]$latest,
    .env = env
  )
}

test_that("sitrep() has no latest/outdated columns by default", {
  mock_updates_env(list(stats = list(version = "1.0.0", source = "GitHub", latest = "9.0.0")))
  out <- capture.output(result <- mediationverse_sitrep())
  expect_false(any(c("latest", "outdated") %in% names(result)))
  expect_true(any(grepl("updates = TRUE", out, fixed = TRUE)))
})

test_that("sitrep(updates = TRUE) adds latest and outdated columns", {
  mock_updates_env(list(
    stats = list(version = "0.9.0", source = "GitHub", latest = "0.10.0"),
    utils = list(version = "1.0.0", source = "CRAN", latest = "1.0.0"),
    tools = list(version = "1.0.0", source = "GitHub", latest = NA_character_)
  ))
  out <- capture.output(result <- mediationverse_sitrep(updates = TRUE))
  expect_named(result, c("package", "installed", "version", "source", "installed_from",
                         "latest", "outdated"))
  expect_equal(result$latest, c("0.10.0", "1.0.0", NA))
  # 0.9.0 < 0.10.0 numerically (a string comparison would say the opposite).
  expect_equal(result$outdated, c(TRUE, FALSE, NA))
  txt <- paste(out, collapse = "\n")
  expect_match(txt, "0.9.0 -> 0.10.0", fixed = TRUE)
  expect_match(txt, "Could not check: tools", fixed = TRUE)
  expect_match(txt, "mediationverse_update()", fixed = TRUE)
})

test_that("sitrep(updates = TRUE) says everything is current when nothing is outdated", {
  mock_updates_env(list(stats = list(version = "2.0.0", source = "GitHub", latest = "1.0.0")))
  out <- capture.output(result <- mediationverse_sitrep(updates = TRUE))
  expect_false(result$outdated)
  expect_match(paste(out, collapse = "\n"), "up to date")
})

test_that("sitrep(updates = TRUE) leaves latest NA for members that are not installed", {
  real_require <- base::requireNamespace
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "cli")) FALSE else FALSE
    },
    .package = "base"
  )
  testthat::local_mocked_bindings(
    pkg_latest = function(pkg, source) stop("must not look up a missing member")
  )
  out <- capture.output(result <- mediationverse_sitrep(updates = TRUE))
  expect_true(all(is.na(result$latest)))
  expect_true(all(is.na(result$outdated)))
})

test_that("sitrep() validates updates", {
  for (bad in list(NA, "yes", c(TRUE, FALSE), NULL, 1)) {
    expect_error(mediationverse_sitrep(updates = bad), "TRUE or FALSE")
  }
})

test_that("sitrep(updates = TRUE) prints the cli report too", {
  skip_if_not_installed("cli")
  testthat::local_mocked_bindings(
    mv_core_packages = function() "stats",
    mv_source = function(pkg) "GitHub",
    pkg_version = function(pkg) "0.1.0",
    pkg_provenance = function(pkg) "GitHub",
    pkg_latest = function(pkg, source) "0.2.0"
  )
  msgs <- character()
  result <- withCallingHandlers(
    mediationverse_sitrep(updates = TRUE),
    message = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )
  expect_true(result$outdated)
  expect_match(paste(msgs, collapse = "\n"), "0.1.0 -> 0.2.0", fixed = TRUE)
})

test_that("is_outdated() compares numerically and tolerates unknowns", {
  expect_true(is_outdated("0.9.0", "0.10.0"))
  expect_false(is_outdated("0.10.0", "0.9.0"))
  expect_false(is_outdated("1.0.0", "1.0.0"))
  expect_false(is_outdated("1.0.0.9000", "1.0.0"))
  expect_true(is.na(is_outdated(NA_character_, "1.0.0")))
  expect_true(is.na(is_outdated("1.0.0", NA_character_)))
  expect_true(is.na(is_outdated("not a version", "1.0.0")))
})
