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

## ---- install-dispatch paths (mocked; never touches the network) -------------
## These drive the installer-selection and spec-building logic without running a
## real install: `pak::pak` / `remotes::install_github` / `utils::install.packages`
## are mocked to recorders, and `base::requireNamespace` is mocked to force the
## pak-vs-remotes branch.

test_that("pak path builds GitHub slugs + bare CRAN names and returns invisibly", {
  skip_if_not_installed("pak")
  rec <- new.env()
  local_mocked_bindings(
    pak = function(pkg, ...) {
      rec$specs <- pkg
      invisible(NULL)
    },
    .package = "pak"
  )
  out <- expect_invisible(
    mediationverse_update(c("medfit", "probmed", "RMediation"))
  )
  expect_equal(out, c("medfit", "probmed", "RMediation"))
  # GitHub packages -> data-wise/<pkg>; CRAN package -> bare name
  expect_equal(
    unname(rec$specs),
    c("data-wise/medfit", "data-wise/probmed", "RMediation")
  )
})

test_that("pak path defaults to all six packages when `packages` is NULL", {
  skip_if_not_installed("pak")
  rec <- new.env()
  local_mocked_bindings(
    pak = function(pkg, ...) {
      rec$specs <- pkg
      invisible(NULL)
    },
    .package = "pak"
  )
  out <- mediationverse_update()
  expect_setequal(
    out,
    c("mediationverse", "medfit", "probmed", "medrobust", "medsim", "RMediation")
  )
  # five GitHub slugs + the one CRAN package
  expect_true(all(c("data-wise/mediationverse", "data-wise/medfit",
                    "data-wise/probmed", "data-wise/medrobust",
                    "data-wise/medsim", "RMediation") %in% rec$specs))
})

test_that("pak path falls back to message() when cli is unavailable", {
  skip_if_not_installed("pak")
  local_mocked_bindings(
    requireNamespace = function(package, ...) package != "cli",  # cli "missing"
    .package = "base"
  )
  local_mocked_bindings(pak = function(pkg, ...) invisible(NULL), .package = "pak")
  expect_message(
    expect_message(mediationverse_update("medfit"), "pak"),  # "Updating ... pak"
    "Updated"                                                 # success message
  )
})

test_that("remotes fallback installs GitHub and CRAN packages separately", {
  skip_if_not_installed("remotes")
  local_mocked_bindings(
    requireNamespace = function(package, ...) package != "pak",  # pak "missing"
    .package = "base"
  )
  gh <- new.env(); gh$slugs <- character(0)
  cran <- new.env(); cran$pkgs <- character(0)
  local_mocked_bindings(
    install_github = function(repo, ...) { gh$slugs <- c(gh$slugs, repo); invisible() },
    .package = "remotes"
  )
  local_mocked_bindings(
    install.packages = function(pkgs, ...) { cran$pkgs <- c(cran$pkgs, pkgs); invisible() },
    .package = "utils"
  )
  out <- mediationverse_update(c("medfit", "RMediation"))
  expect_equal(out, c("medfit", "RMediation"))
  expect_equal(unname(gh$slugs), "data-wise/medfit")  # GitHub via install_github
  expect_equal(cran$pkgs, "RMediation")               # CRAN via install.packages
})

test_that("remotes fallback errors when remotes itself is unavailable", {
  local_mocked_bindings(
    requireNamespace = function(package, ...) FALSE,  # nothing available
    .package = "base"
  )
  expect_error(
    mediationverse_update("medfit"),
    "remotes"
  )
})
