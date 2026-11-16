mock_env <- function(versions, installed = names(versions), openmx = TRUE,
                     env = parent.frame()) {
  testthat::local_mocked_bindings(
    pkg_installed = function(pkg) {
      if (identical(pkg, "OpenMx")) openmx else pkg %in% installed
    },
    pkg_version = function(pkg) {
      if (pkg %in% names(versions)) versions[[pkg]] else NA_character_
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

test_that("a member meeting its minimum passes; an old one fails with a fix", {
  mock_env(c(medfit = "0.3.1", RMediation = "1.6.1"))
  ok <- mediationverse:::check_min_versions()
  expect_identical(ok$status[ok$check == "version:medfit"], "pass")

  mock_env(c(medfit = "0.2.0", RMediation = "1.6.1"))
  old <- mediationverse:::check_min_versions()
  row <- old[old$check == "version:medfit", ]
  expect_identical(row$status, "fail")
  expect_match(row$message, "older than the required 0.3.1")
  expect_match(row$fix, "Data-Wise/medfit", fixed = TRUE)
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

test_that("missing OpenMx warns with an install fix; present passes", {
  mock_env(c(medfit = "0.7.0"), openmx = FALSE)
  warn <- mediationverse:::check_optional_deps()
  expect_identical(warn$status, "warn")
  expect_match(warn$message, "mbco")
  expect_match(warn$fix, "OpenMx")

  mock_env(c(medfit = "0.7.0"), openmx = TRUE)
  expect_identical(mediationverse:::check_optional_deps()$status, "pass")
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
