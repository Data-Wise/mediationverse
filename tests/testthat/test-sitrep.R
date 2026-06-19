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

test_that("mediationverse_sitrep() medfit and RMediation are CRAN; others are GitHub", {
  result <- mediationverse_sitrep()
  cran_pkgs   <- result$package[result$source == "CRAN"]
  github_pkgs <- result$package[result$source == "GitHub"]
  expect_setequal(cran_pkgs, c("medfit", "RMediation"))
  expect_setequal(github_pkgs, c("probmed", "medrobust", "medsim"))
})

test_that("mediationverse_sitrep() returns invisibly and prints without error", {
  expect_invisible(mediationverse_sitrep())
  expect_no_error(mediationverse_sitrep())
})
