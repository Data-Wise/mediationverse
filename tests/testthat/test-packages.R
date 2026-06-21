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
