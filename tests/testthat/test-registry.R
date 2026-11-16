test_that("registry has the expected shape and one row per package", {
  reg <- mediationverse:::mv_registry()

  expect_s3_class(reg, "data.frame")
  expect_named(reg, c("package", "repo", "source", "core", "min_version", "recommended_version"))
  expect_false(anyDuplicated(reg$package) > 0)
  expect_type(reg$core, "logical")
  expect_true(all(reg$source %in% c("CRAN", "GitHub")))
  expect_true(all(grepl("^Data-Wise/", reg$repo)))
})

test_that("core packages are the six members, in listing order, without self", {
  expect_identical(
    mediationverse:::mv_core_packages(),
    c("medfit", "probmed", "RMediation", "medrobust", "medsim", "missingmed")
  )
  expect_false("mediationverse" %in% mediationverse:::mv_core_packages())
})

test_that("mv_all_packages() lists mediationverse first", {
  all_pkgs <- mediationverse:::mv_all_packages()
  expect_identical(all_pkgs[1], "mediationverse")
  expect_setequal(all_pkgs, c("mediationverse", mediationverse:::mv_core_packages()))
})

test_that("only RMediation is CRAN-sourced; the rest are GitHub", {
  expect_identical(mediationverse:::mv_cran_packages(), "RMediation")
  expect_setequal(
    mediationverse:::mv_github_packages(),
    c("mediationverse", "medfit", "probmed", "medrobust", "medsim", "missingmed")
  )
  expect_identical(mediationverse:::mv_source("RMediation"), "CRAN")
  expect_identical(mediationverse:::mv_source("medfit"), "GitHub")
})

test_that("mv_repos() is a named vector keyed by package", {
  repos <- mediationverse:::mv_repos()
  expect_named(repos, mediationverse:::mv_all_packages())
  expect_identical(repos[["RMediation"]], "Data-Wise/rmediation")
  expect_identical(repos[["medfit"]], "Data-Wise/medfit")
})

test_that("minimum versions are valid version strings or NA", {
  reg <- mediationverse:::mv_registry()
  declared <- reg$min_version[!is.na(reg$min_version)]
  expect_true(length(declared) > 0)
  expect_no_error(lapply(declared, package_version))
  expect_identical(reg$min_version[reg$package == "medfit"], "0.3.1")
  expect_identical(reg$min_version[reg$package == "RMediation"], "1.5.0")
})

test_that("medfit's recommended version is at or above its minimum", {
  reg <- mediationverse:::mv_registry()
  row <- reg[reg$package == "medfit", ]
  expect_identical(row$recommended_version, "0.5.0")
  expect_true(package_version(row$recommended_version) >= package_version(row$min_version))
  # Only members with a minimum may have a recommended version.
  with_rec <- reg[!is.na(reg$recommended_version), ]
  expect_false(any(is.na(with_rec$min_version)))
})

test_that("DESCRIPTION's medfit constraint does not exceed the registry minimum", {
  desc <- tryCatch(
    utils::packageDescription("mediationverse", fields = "Imports"),
    error = function(e) NA
  )
  skip_if(is.na(desc[[1]]), "mediationverse DESCRIPTION not available")
  m <- regmatches(desc[[1]], regexpr("medfit \\(>= [0-9.]+\\)", desc[[1]]))
  skip_if(length(m) == 0, "no medfit constraint in Imports")
  declared <- sub(".*>= ([0-9.]+)\\).*", "\\1", m)
  reg_min <- mediationverse:::mv_registry()$min_version[
    mediationverse:::mv_registry()$package == "medfit"
  ]
  expect_true(package_version(declared) <= package_version(reg_min))
})

test_that("public functions use the registry's member list", {
  expect_identical(
    mediationverse_packages(include_self = FALSE)$package,
    mediationverse:::mv_core_packages()
  )
  expect_identical(
    mediationverse_packages()$package,
    mediationverse:::mv_all_packages()
  )
  expect_identical(
    mediationverse_sitrep()$package,
    mediationverse:::mv_core_packages()
  )
})
