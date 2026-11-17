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
  valid <- c("mediationverse", "probmed", "medrobust", "medsim", "missingmed", "RMediation", "medfit")
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
  expected <- c("mediationverse", "medfit", "probmed", "RMediation", "medrobust", "medsim", "missingmed")
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
    c("mediationverse", "medfit", "probmed", "medrobust", "medsim", "missingmed", "RMediation")
  )
  # six GitHub slugs + the one CRAN package
  expect_true(all(c("data-wise/mediationverse", "data-wise/medfit",
                    "data-wise/probmed", "data-wise/medrobust",
                    "data-wise/medsim", "data-wise/missingmed", "RMediation") %in% rec$specs))
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

## ---- only_outdated and dry_run (mocked; no network, no installs) -------------

mock_update_env <- function(installed, latest, env = parent.frame()) {
  # installed: named character (package -> version; absent names are not installed)
  # latest: named character (package -> latest, NA when unknown)
  testthat::local_mocked_bindings(
    pkg_state = function(pkg) if (pkg %in% names(installed)) "ok" else "absent",
    pkg_version = function(pkg) installed[[pkg]],
    pkg_latest = function(pkg, source) {
      if (pkg %in% names(latest)) latest[[pkg]] else NA_character_
    },
    .env = env
  )
}

test_that("dry_run prints the plan and installs nothing", {
  skip_if_not_installed("pak")
  local_mocked_bindings(
    pak = function(...) stop("dry_run must not install"),
    .package = "pak"
  )
  msgs <- character()
  out <- withCallingHandlers(
    mediationverse_update(c("medfit", "RMediation"), dry_run = TRUE),
    message = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )
  expect_equal(out, c("medfit", "RMediation"))
  txt <- paste(msgs, collapse = "\n")
  expect_match(txt, "medfit")
  expect_match(txt, "RMediation")
  expect_match(txt, "dry run", ignore.case = TRUE)
})

test_that("dry_run does not call the remotes fallback either", {
  real_require <- base::requireNamespace
  local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "pak")) FALSE else real_require(package, ...)
    },
    .package = "base"
  )
  local_mocked_bindings(
    install_github = function(...) stop("dry_run must not install"),
    .package = "remotes"
  )
  local_mocked_bindings(
    install.packages = function(...) stop("dry_run must not install"),
    .package = "utils"
  )
  expect_equal(
    suppressMessages(mediationverse_update("medfit", dry_run = TRUE)),
    "medfit"
  )
})

test_that("only_outdated keeps outdated and not-installed members, drops current ones", {
  skip_if_not_installed("pak")
  mock_update_env(
    installed = c(medfit = "0.7.0", probmed = "0.4.1", RMediation = "1.6.1"),
    latest = c(medfit = "0.18.0", probmed = "0.4.1", RMediation = "1.6.1",
               medsim = "0.6.0")
  )
  out <- suppressMessages(
    mediationverse_update(c("medfit", "probmed", "RMediation", "medsim"),
                          only_outdated = TRUE, dry_run = TRUE)
  )
  expect_equal(out, c("medfit", "medsim"))
})

test_that("only_outdated keeps members whose latest version is unknown", {
  mock_update_env(
    installed = c(medfit = "0.7.0"),
    latest = character()
  )
  out <- suppressMessages(
    mediationverse_update("medfit", only_outdated = TRUE, dry_run = TRUE)
  )
  expect_equal(out, "medfit")
})

test_that("only_outdated with everything current installs nothing", {
  skip_if_not_installed("pak")
  mock_update_env(
    installed = c(medfit = "0.18.0"),
    latest = c(medfit = "0.18.0")
  )
  local_mocked_bindings(
    pak = function(...) stop("nothing should be installed"),
    .package = "pak"
  )
  msgs <- character()
  out <- withCallingHandlers(
    mediationverse_update("medfit", only_outdated = TRUE),
    message = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )
  expect_equal(out, character(0))
  expect_match(paste(msgs, collapse = "\n"), "up to date")
})

test_that("only_outdated and dry_run still validate package names first", {
  expect_error(
    mediationverse_update("notapackage", only_outdated = TRUE, dry_run = TRUE),
    "Unknown packages"
  )
})

test_that("only_outdated and dry_run must be TRUE or FALSE", {
  expect_error(mediationverse_update("medfit", dry_run = NA), "TRUE or FALSE")
  expect_error(mediationverse_update("medfit", only_outdated = "yes"), "TRUE or FALSE")
})
