test_that("mediationverse_packages() returns data frame with expected structure", {
  result <- mediationverse_packages()

  expect_s3_class(result, "data.frame")
  expect_s3_class(result, "mediationverse_packages")
  expect_named(result, c("package", "installed", "version", "attached"))
  expect_type(result$package, "character")
  expect_type(result$installed, "logical")
  expect_type(result$version, "character")
  expect_type(result$attached, "logical")
})

test_that("mediationverse_packages() includes core ecosystem packages", {
  result <- mediationverse_packages(include_self = FALSE)
  expect_setequal(
    result$package,
    c("medfit", "probmed", "RMediation", "medrobust", "medsim")
  )
})

test_that("mediationverse_packages(include_self = TRUE) includes mediationverse itself", {
  result <- mediationverse_packages(include_self = TRUE)
  expect_true("mediationverse" %in% result$package)
  expect_equal(nrow(result), 6L)
})

test_that("mediationverse_packages() version is NA for uninstalled packages", {
  result <- mediationverse_packages()
  # Installed packages must have non-NA version
  for (i in seq_len(nrow(result))) {
    if (result$installed[i]) {
      expect_false(is.na(result$version[i]), label = result$package[i])
    } else {
      expect_true(is.na(result$version[i]), label = result$package[i])
    }
  }
})

test_that("print.mediationverse_packages() runs without error", {
  result <- mediationverse_packages()
  expect_no_error(print(result))
  expect_invisible(print(result))
})

test_that("print.mediationverse_packages() shows attached + not-installed rows (cli)", {
  # Hand-built object exercises all three cli branches: installed+attached,
  # installed-not-attached, and not-installed.
  fake <- data.frame(
    package   = c("medfit", "probmed", "medsim"),
    installed = c(TRUE, TRUE, FALSE),
    version   = c("0.3.1", "0.1.0", NA_character_),
    attached  = c(TRUE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  class(fake) <- c("mediationverse_packages", "data.frame")

  expect_no_error(print(fake))
  expect_invisible(print(fake))
})

test_that("print.mediationverse_packages() falls back to plain cat without cli", {
  skip_if_not_installed("cli")  # mock only meaningful when cli is normally present
  fake <- data.frame(
    package   = c("medfit", "medsim"),
    installed = c(TRUE, FALSE),
    version   = c("0.3.1", NA_character_),
    attached  = c(TRUE, FALSE),
    stringsAsFactors = FALSE
  )
  class(fake) <- c("mediationverse_packages", "data.frame")

  real_require <- base::requireNamespace  # capture before mocking to avoid recursion
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "cli")) FALSE else real_require(package, ...)
    },
    .package = "base"
  )

  out <- capture.output(print(fake))
  expect_true(any(grepl("mediationverse packages", out)))
  expect_true(any(grepl("\\[x\\] medfit", out)))            # installed branch
  expect_true(any(grepl("\\(attached\\)", out)))            # attached suffix
  expect_true(any(grepl("\\[ \\] medsim", out)))            # not-installed branch
})

## ---- internal version helper (attach.R) ------------------------------------

test_that("package_version_string() reports versions and flags uninstalled pkgs", {
  res <- mediationverse:::package_version_string(c("stats", "__no_such_pkg__"))
  expect_length(res, 2L)
  expect_match(res[["stats"]], "^[0-9]")              # a real version string
  expect_identical(res[["__no_such_pkg__"]], "(not installed)")
})

test_that("is_attached() detects search-path membership", {
  expect_true(mediationverse:::is_attached("stats"))  # always attached
  expect_false(mediationverse:::is_attached("__not_attached_pkg__"))
})
