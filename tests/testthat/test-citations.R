fake_citation <- function(title, version = "1.0") {
  utils::bibentry(
    "Manual",
    title = title,
    author = utils::person("Ada", "Lovelace"),
    year = "2026",
    note = paste("R package version", version),
    key = title
  )
}

# Mock the helpers: `citations` is a named list of citation objects, NULL
# entries and "error" entries; names not listed are treated as not installed.
mock_citation_helpers <- function(citations, env = parent.frame()) {
  testthat::local_mocked_bindings(
    pkg_installed = function(pkg) pkg %in% names(citations),
    pkg_citation = function(pkg) citations[[pkg]],
    .env = env
  )
}

# Run citations(), capturing stdout (citation text) and cli messages.
run_citations <- function(...) {
  msgs <- character()
  out <- utils::capture.output(
    res <- withCallingHandlers(
      mediationverse_citations(...),
      message = function(m) {
        msgs <<- c(msgs, conditionMessage(m))
        invokeRestart("muffleMessage")
      }
    )
  )
  list(res = res, out = out, msgs = msgs)
}

test_that("citations() returns a classed list and prints text citations", {
  mock_citation_helpers(list(
    medfit = fake_citation("medfit"),
    RMediation = fake_citation("RMediation", "1.6.1")
  ))

  r <- run_citations()

  expect_s3_class(r$res, "mediationverse_citations")
  expect_named(r$res, c("medfit", "RMediation"))
  expect_identical(attr(r$res, "style"), "text")
  expect_true(any(grepl("medfit", r$out)))
  expect_true(any(grepl("RMediation", r$out)))
})

test_that("citations() lists not-installed members without aborting", {
  mock_citation_helpers(list(medfit = fake_citation("medfit")))

  r <- run_citations()

  expect_named(r$res, "medfit")
  expect_setequal(
    attr(r$res, "not_installed"),
    c("probmed", "RMediation", "medrobust", "medsim", "missingmed")
  )
  expect_true(any(grepl("Not installed", r$msgs)))
})

test_that("citations() handles an empty or missing citation", {
  # RMediation returns an empty citation and probmed errors (NULL); both are
  # installed, so they must be reported as having no citation.
  testthat::local_mocked_bindings(
    pkg_installed = function(pkg) pkg %in% c("medfit", "RMediation", "probmed"),
    pkg_citation = function(pkg) {
      switch(pkg,
        medfit = fake_citation("medfit"),
        RMediation = utils::citation("stats")[0],
        probmed = NULL
      )
    }
  )

  r <- run_citations()

  expect_named(r$res, "medfit")
  expect_setequal(attr(r$res, "no_citation"), c("RMediation", "probmed"))
  expect_true(any(grepl("No citation available", r$msgs)))
})

test_that("citations() produces bibtex when asked", {
  mock_citation_helpers(list(medfit = fake_citation("medfit")))

  r <- run_citations(style = "bibtex")

  expect_identical(attr(r$res, "style"), "bibtex")
  expect_true(any(grepl("@Manual", r$out, fixed = TRUE)))
})

test_that("citations() excludes mediationverse unless include_self = TRUE", {
  mock_citation_helpers(list(
    mediationverse = fake_citation("mediationverse"),
    medfit = fake_citation("medfit")
  ))

  expect_false("mediationverse" %in% names(run_citations()$res))
  expect_true("mediationverse" %in% names(run_citations(include_self = TRUE)$res))
})

test_that("citations() notes auto-generated commit hashes", {
  mock_citation_helpers(list(
    medfit = fake_citation("medfit", "0.7.0 (commit 1a2b3c4d5e6f)")
  ))

  r <- run_citations()

  expect_true(any(grepl("commit hash", r$msgs)))
})

test_that("citations() omits the commit-hash note for ordinary citations", {
  mock_citation_helpers(list(medfit = fake_citation("medfit")))

  expect_false(any(grepl("commit hash", run_citations()$msgs)))
})

test_that("citations() rejects an unknown style", {
  expect_error(mediationverse_citations(style = "apa"), "should be one of")
})

test_that("pkg_citation() returns NULL for a package that does not exist", {
  expect_null(mediationverse:::pkg_citation("__no_such_pkg__"))
})

test_that("pkg_installed() reflects installation state", {
  expect_true(mediationverse:::pkg_installed("stats"))
  expect_false(mediationverse:::pkg_installed("__no_such_pkg__"))
})
