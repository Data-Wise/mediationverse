# Every test mocks the attach step: real members must never be attached.
mock_attach <- function(states, attached = character(), failing = character(),
                        env = parent.frame()) {
  calls <- new.env()
  calls$pkgs <- character()
  testthat::local_mocked_bindings(
    pkg_state = function(pkg) if (is.na(states[pkg])) "absent" else unname(states[pkg]),
    is_attached = function(x) x %in% attached,
    pkg_attach = function(pkg) {
      if (pkg %in% failing) stop("boom")
      calls$pkgs <- c(calls$pkgs, pkg)
      invisible()
    },
    .env = env
  )
  calls
}

run_attach_all <- function() {
  msgs <- character()
  res <- withCallingHandlers(
    withVisible(mediationverse_attach_all()),
    message = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )
  list(res = res$value, visible = res$visible, msgs = msgs)
}

all_ok <- function() {
  stats::setNames(rep("ok", length(mv_core_packages())), mv_core_packages())
}

test_that("attach_all() attaches installed members and reports statuses", {
  calls <- mock_attach(all_ok())
  r <- run_attach_all()
  expect_setequal(calls$pkgs, mv_core_packages())
  expect_true(all(r$res == "attached"))
  expect_setequal(names(r$res), mv_core_packages())
})

test_that("attach_all() skips already attached members", {
  calls <- mock_attach(all_ok(), attached = "medfit")
  r <- run_attach_all()
  expect_false("medfit" %in% calls$pkgs)
  expect_equal(unname(r$res["medfit"]), "already attached")
})

test_that("attach_all() reports absent members", {
  st <- all_ok()
  st["probmed"] <- "absent"
  calls <- mock_attach(st)
  r <- run_attach_all()
  expect_equal(unname(r$res["probmed"]), "not installed")
  expect_false("probmed" %in% calls$pkgs)
  expect_match(paste(r$msgs, collapse = "\n"), "probmed")
})

test_that("attach_all() survives a member that fails to load", {
  st <- all_ok()
  st["medsim"] <- "broken"
  mock_attach(st, failing = "medrobust")
  r <- run_attach_all()
  expect_equal(unname(r$res["medsim"]), "failed to load")
  expect_equal(unname(r$res["medrobust"]), "failed to load")
  expect_equal(unname(r$res["medfit"]), "attached")
})

test_that("attach_all() returns a named character vector invisibly", {
  mock_attach(all_ok())
  r <- run_attach_all()
  expect_false(r$visible)
  expect_type(r$res, "character")
  expect_named(r$res)
})

test_that("attach_all() suggests conflicts when 2+ are attached", {
  mock_attach(all_ok())
  expect_match(paste(run_attach_all()$msgs, collapse = "\n"), "mediationverse_conflicts")

  st <- stats::setNames(rep("absent", length(mv_core_packages())), mv_core_packages())
  st["medfit"] <- "ok"
  mock_attach(st)
  expect_false(grepl("mediationverse_conflicts", paste(run_attach_all()$msgs, collapse = "\n")))
})

test_that("pkg_attach() attaches a package quietly and invisibly", {
  skip_if(is_attached("tools"), "tools already attached")
  withr_free <- function() detach("package:tools", unload = FALSE, character.only = TRUE)
  on.exit(withr_free(), add = TRUE)
  res <- withVisible(pkg_attach("tools"))
  expect_false(res$visible)
  expect_true(is_attached("tools"))
})
