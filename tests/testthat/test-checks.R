mock_env <- function(versions, installed = names(versions), openmx = TRUE,
                     mbco = TRUE, openmx_version = "2.22.11",
                     env = parent.frame()) {
  testthat::local_mocked_bindings(
    pkg_installed = function(pkg) {
      if (identical(pkg, "OpenMx")) openmx else pkg %in% installed
    },
    pkg_has_export = function(pkg, name) mbco,
    pkg_version = function(pkg) {
      if (identical(pkg, "OpenMx")) {
        openmx_version
      } else if (pkg %in% names(versions)) {
        versions[[pkg]]
      } else {
        NA_character_
      }
    },
    find_conflicts = function(pkgs) {
      data.frame(
        function_name = character(0), packages = character(0),
        winner = character(0), stringsAsFactors = FALSE
      )
    },
    .env = env
  )
}

test_that("mv_checks() returns the documented columns and valid statuses", {
  mock_env(c(medfit = "0.7.0", RMediation = "1.6.1"))

  res <- mediationverse:::mv_checks()

  expect_s3_class(res, "data.frame")
  expect_named(res, c("check", "status", "message", "fix"))
  expect_true(all(res$status %in% c("pass", "warn", "fail")))
  expect_false(anyDuplicated(res$check) > 0)
})

test_that("a member at or above the recommended version passes", {
  mock_env(c(medfit = "0.5.0", RMediation = "1.6.1"))
  ok <- mediationverse:::check_min_versions()
  expect_identical(ok$status[ok$check == "version:medfit"], "pass")

  mock_env(c(medfit = "0.7.0", RMediation = "1.6.1"))
  ok <- mediationverse:::check_min_versions()
  expect_identical(ok$status[ok$check == "version:medfit"], "pass")
})

test_that("a member below the minimum fails with a fix", {
  mock_env(c(medfit = "0.2.0", RMediation = "1.6.1"))
  old <- mediationverse:::check_min_versions()
  row <- old[old$check == "version:medfit", ]
  expect_identical(row$status, "fail")
  expect_match(row$message, "older than the required 0.3.1")
  expect_match(row$fix, "Data-Wise/medfit", fixed = TRUE)
})

test_that("medfit 0.3.1 and CRAN's 0.3.2 only warn: they predate the recommended fixes", {
  for (ver in c("0.3.1", "0.3.2", "0.4.0")) {
    mock_env(c(medfit = ver, RMediation = "1.6.1"))
    res <- mediationverse:::check_min_versions()
    row <- res[res$check == "version:medfit", ]
    expect_identical(row$status, "warn", info = ver)
    expect_match(row$message, "predates 0.5.0", info = ver)
    expect_match(row$message, "result-changing", info = ver)
    expect_match(row$fix, "Data-Wise/medfit", fixed = TRUE)
  }
})

test_that("a member without a recommended version passes once it meets the minimum", {
  mock_env(c(medfit = "0.7.0", RMediation = "1.5.0"))
  res <- mediationverse:::check_min_versions()
  expect_identical(res$status[res$check == "version:RMediation"], "pass")
})

test_that("a not-installed member with a minimum is a warning, not a failure", {
  mock_env(c(RMediation = "1.6.1"), installed = "RMediation")

  res <- mediationverse:::check_min_versions()

  expect_identical(res$status[res$check == "version:medfit"], "warn")
  expect_match(res$message[res$check == "version:medfit"], "not installed")
})

test_that("an unreadable version is a warning", {
  testthat::local_mocked_bindings(
    pkg_installed = function(pkg) TRUE,
    pkg_version = function(pkg) NA_character_
  )

  res <- mediationverse:::check_min_versions()

  expect_true(all(res$status == "warn"))
})

test_that("missing OpenMx warns with an install fix", {
  mock_env(c(medfit = "0.7.0", RMediation = "1.6.1"), openmx = FALSE)
  warn <- mediationverse:::check_optional_deps()
  expect_identical(warn$status, "warn")
  expect_match(warn$message, "mbco")
  expect_match(warn$fix, "OpenMx")
})

test_that("OpenMx plus RMediation exporting mbco() passes", {
  mock_env(c(medfit = "0.7.0", RMediation = "1.6.1"), openmx = TRUE, mbco = TRUE)
  expect_identical(mediationverse:::check_optional_deps()$status, "pass")
})

test_that("OpenMx below RMediation's declared minimum warns; at the minimum passes", {
  mock_env(c(medfit = "0.7.0", RMediation = "1.6.1"), openmx_version = "2.12")
  old <- mediationverse:::check_optional_deps()
  expect_identical(old$status, "warn")
  expect_match(old$message, "OpenMx 2.12 is older than the 2.13")
  expect_match(old$fix, "OpenMx")

  mock_env(c(medfit = "0.7.0", RMediation = "1.6.1"), openmx_version = "2.13")
  expect_identical(mediationverse:::check_optional_deps()$status, "pass")

  mock_env(c(medfit = "0.7.0", RMediation = "1.6.1"), openmx_version = "2.22.11")
  expect_identical(mediationverse:::check_optional_deps()$status, "pass")
})

test_that("an unreadable OpenMx version warns instead of passing", {
  mock_env(c(medfit = "0.7.0", RMediation = "1.6.1"), openmx_version = NA_character_)
  res <- mediationverse:::check_optional_deps()
  expect_identical(res$status, "warn")
  expect_match(res$message, "version could not be read")
  expect_match(res$message, "2.13", fixed = TRUE)
  expect_match(res$fix, "OpenMx")
})

test_that("OpenMx present but RMediation absent does not claim mbco() is available", {
  mock_env(c(medfit = "0.7.0"), installed = "medfit", openmx = TRUE)
  res <- mediationverse:::check_optional_deps()
  expect_identical(res$status, "warn")
  expect_match(res$message, "RMediation is not")
  expect_match(res$fix, "RMediation")
  expect_match(res$message, "unavailable")
  expect_false(grepl("(?<!un)available", res$message, perl = TRUE))
})

test_that("OpenMx present but RMediation without mbco() warns", {
  mock_env(c(medfit = "0.7.0", RMediation = "1.6.1"), openmx = TRUE, mbco = FALSE)
  res <- mediationverse:::check_optional_deps()
  expect_identical(res$status, "warn")
  expect_match(res$message, "does not export mbco")
})

test_that("mbco() is not reported available when RMediation is below its minimum", {
  mock_env(c(medfit = "0.7.0", RMediation = "1.4.0"), openmx = TRUE, mbco = TRUE)
  res <- mediationverse:::check_optional_deps()
  expect_identical(res$status, "warn")
  expect_match(res$message, "RMediation 1.4.0 is older than the required 1.5.0")
  expect_match(res$fix, "RMediation")
})

test_that("RMediation at its minimum with mbco() passes", {
  mock_env(c(medfit = "0.7.0", RMediation = "1.5.0"), openmx = TRUE, mbco = TRUE)
  expect_identical(mediationverse:::check_optional_deps()$status, "pass")
})

test_that("an unreadable RMediation version does not pass the mbco() check", {
  mock_env(c(medfit = "0.7.0"), installed = c("medfit", "RMediation"), openmx = TRUE, mbco = TRUE)
  res <- mediationverse:::check_optional_deps()
  expect_identical(res$status, "warn")
  expect_match(res$message, "RMediation's version could not be read")
})

test_that("pkg_has_export() reflects real exports and is FALSE for missing packages", {
  expect_true(mediationverse:::pkg_has_export("stats", "sd"))
  expect_false(mediationverse:::pkg_has_export("stats", "not_a_function"))
  expect_false(mediationverse:::pkg_has_export("__no_such_pkg__", "x"))
})

test_that("conflicts check warns and names the functions", {
  testthat::local_mocked_bindings(
    pkg_installed = function(pkg) TRUE,
    find_conflicts = function(pkgs) {
      data.frame(
        function_name = c("ci", "te"), packages = c("a, b", "a, b"),
        winner = c("a", "a"), stringsAsFactors = FALSE
      )
    }
  )

  res <- mediationverse:::check_conflicts()

  expect_identical(res$status, "warn")
  expect_match(res$message, "2 functions")
  expect_match(res$message, "ci, te", fixed = TRUE)
})

test_that("conflicts check warns when some exports could not be read", {
  testthat::local_mocked_bindings(
    pkg_installed = function(pkg) TRUE,
    find_conflicts = function(pkgs) {
      structure(
        data.frame(
          function_name = character(0), packages = character(0),
          winner = character(0), stringsAsFactors = FALSE
        ),
        failed_lookup = "probmed"
      )
    }
  )

  res <- mediationverse:::check_conflicts()

  expect_identical(res$status, "warn")
  expect_match(res$message, "probmed")
  expect_match(res$message, "incomplete")
  expect_false(grepl("No export conflicts among installed", res$message))
})

test_that("conflicts check still reports found conflicts alongside a failed lookup", {
  testthat::local_mocked_bindings(
    pkg_installed = function(pkg) TRUE,
    find_conflicts = function(pkgs) {
      structure(
        data.frame(
          function_name = "ci", packages = "a, b", winner = "a",
          stringsAsFactors = FALSE
        ),
        failed_lookup = "medsim"
      )
    }
  )

  res <- mediationverse:::check_conflicts()

  expect_identical(res$status, "warn")
  expect_match(res$message, "1 function exported")
  expect_match(res$message, "medsim")
})

test_that("conflicts check passes when nothing conflicts", {
  mock_env(c(medfit = "0.7.0"))
  expect_identical(mediationverse:::check_conflicts()$status, "pass")
})

# Run sitrep, capturing stdout and cli messages.
run_sitrep <- function(...) {
  msgs <- character()
  out <- utils::capture.output(
    res <- withCallingHandlers(
      mediationverse_sitrep(...),
      message = function(m) {
        msgs <<- c(msgs, conditionMessage(m))
        invokeRestart("muffleMessage")
      }
    )
  )
  list(res = res, text = c(out, msgs))
}

test_that("sitrep() default output is unchanged apart from the hint", {
  r <- run_sitrep()

  expect_named(r$res, c("package", "installed", "version", "source"))
  expect_null(attr(r$res, "checks"))
  expect_true(any(grepl("checks = TRUE", r$text, fixed = TRUE)))
  expect_false(any(grepl("Checks", r$text)))
})

test_that("sitrep(checks = TRUE) prints checks and attaches them", {
  mock_env(c(medfit = "0.2.0", RMediation = "1.6.1"), openmx = FALSE)

  r <- run_sitrep(checks = TRUE)

  expect_named(r$res, c("package", "installed", "version", "source"))
  checks <- attr(r$res, "checks")
  expect_s3_class(checks, "data.frame")
  expect_named(checks, c("check", "status", "message", "fix"))
  expect_true(any(grepl("Checks", r$text)))
  expect_true(any(grepl("older than the required", r$text)))
  expect_false(any(grepl("checks = TRUE", r$text, fixed = TRUE)))
})

test_that("sitrep(checks = TRUE) works on the plain-text path without cli", {
  skip_if_not_installed("cli")
  real_require <- base::requireNamespace
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "cli")) FALSE else real_require(package, ...)
    },
    .package = "base"
  )
  mock_env(c(medfit = "0.7.0", RMediation = "1.6.1"), openmx = FALSE)

  out <- utils::capture.output(res <- mediationverse_sitrep(checks = TRUE))

  expect_true(any(grepl("Checks:", out)))
  expect_true(any(grepl("[!]", out, fixed = TRUE)))
  expect_s3_class(attr(res, "checks"), "data.frame")
})

test_that("sitrep() default plain-text path prints the hint", {
  skip_if_not_installed("cli")
  real_require <- base::requireNamespace
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "cli")) FALSE else real_require(package, ...)
    },
    .package = "base"
  )

  out <- utils::capture.output(mediationverse_sitrep())

  expect_true(any(grepl("checks = TRUE", out, fixed = TRUE)))
})

test_that("pkg_version() reads installed versions and returns NA otherwise", {
  expect_match(mediationverse:::pkg_version("stats"), "^[0-9]+\\.")
  expect_true(is.na(mediationverse:::pkg_version("__no_such_pkg__")))
})

test_that("sitrep() does not abort when a member's version cannot be read", {
  testthat::local_mocked_bindings(pkg_version = function(pkg) NA_character_)

  r <- NULL
  expect_no_error(r <- run_sitrep(checks = TRUE))

  expect_true(any(grepl("unknown", r$text)))
  checks <- attr(r$res, "checks")
  expect_s3_class(checks, "data.frame")
  med <- checks[checks$check == "version:medfit", ]
  expect_identical(med$status, "warn")
  expect_match(med$message, "could not be read")
})

test_that("sitrep() plain-text path survives an unreadable member version", {
  skip_if_not_installed("cli")
  real_require <- base::requireNamespace
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "cli")) FALSE else real_require(package, ...)
    },
    .package = "base"
  )
  testthat::local_mocked_bindings(pkg_version = function(pkg) NA_character_)

  out <- character()
  expect_no_error(out <- utils::capture.output(mediationverse_sitrep()))
  expect_true(any(grepl("unknown", out)))
})

test_that("mediationverse_packages() tolerates an unreadable version", {
  testthat::local_mocked_bindings(pkg_version = function(pkg) NA_character_)

  res <- NULL
  expect_no_error(res <- mediationverse_packages())
  expect_true(all(is.na(res$version[res$installed])))
})
