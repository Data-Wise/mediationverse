test_that("mediationverse_update() errors on unknown package names", {
  expect_error(
    mediationverse_update("notapackage"),
    "Unknown packages"
  )
  expect_error(
    mediationverse_update(c("medfit", "totally_fake")),
    "Unknown packages"
  )
})

test_that("mediationverse_update() error message lists the offending package", {
  err <- tryCatch(
    mediationverse_update("notreal"),
    error = function(e) conditionMessage(e)
  )
  expect_match(err, "notreal")
})

test_that("mediationverse_update() error message lists all valid packages", {
  err <- tryCatch(
    mediationverse_update("notreal"),
    error = function(e) conditionMessage(e)
  )
  valid <- c("mediationverse", "probmed", "medrobust", "medsim", "RMediation", "medfit")
  for (pkg in valid) {
    expect_match(err, pkg, fixed = TRUE)
  }
})

test_that("mediationverse_update() knows all expected package names (validation whitelist)", {
  # Test the validation whitelist via the error message: valid packages are named
  # in the error when an *invalid* package is submitted.
  err <- tryCatch(
    mediationverse_update("__invalid__"),
    error = function(e) conditionMessage(e)
  )
  expected <- c("mediationverse", "medfit", "probmed", "RMediation", "medrobust", "medsim")
  for (pkg in expected) {
    expect_match(err, pkg, fixed = TRUE,
      label = paste("valid package listed in error:", pkg))
  }
})
