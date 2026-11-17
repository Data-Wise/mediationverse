# Run `code` with the option set, then restore it (withr is not a declared dependency).
with_quiet <- function(value, code) {
  old <- options(mediationverse.quiet = value)
  on.exit(options(old), add = TRUE)
  force(code)
}

startup_messages <- function() {
  msgs <- character()
  withCallingHandlers(
    .onAttach("lib", "mediationverse"),
    packageStartupMessage = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )
  msgs
}

test_that("mv_quiet() is FALSE by default and TRUE only for TRUE", {
  with_quiet(NULL, expect_false(mv_quiet()))
  with_quiet(TRUE, expect_true(mv_quiet()))
  with_quiet("yes", expect_false(mv_quiet()))
})

test_that(".onAttach() prints the banner by default", {
  testthat::local_mocked_bindings(mediationverse_attach = function() invisible())
  with_quiet(NULL, {
    expect_match(paste(startup_messages(), collapse = "\n"), "Attaching mediationverse")
  })
})

test_that(".onAttach() is silent when quiet", {
  testthat::local_mocked_bindings(mediationverse_attach = function() invisible())
  with_quiet(TRUE, expect_length(startup_messages(), 0L))
})

test_that(".onAttach() still reports a medfit load failure when quiet", {
  testthat::local_mocked_bindings(mediationverse_attach = function() stop("no medfit"))
  with_quiet(TRUE, {
    expect_match(paste(startup_messages(), collapse = "\n"), "medfit could not be loaded")
  })
})

test_that(".onAttach() falls back to a plain banner without cli", {
  real_require <- base::requireNamespace
  testthat::local_mocked_bindings(mediationverse_attach = function() invisible())
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) {
      if (identical(package, "cli")) FALSE else real_require(package, ...)
    },
    .package = "base"
  )
  with_quiet(NULL, {
    txt <- paste(startup_messages(), collapse = "\n")
    expect_match(txt, "-- Attaching mediationverse")
  })
})
