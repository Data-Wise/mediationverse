fake_news <- function(versions, per = 2L) {
  # `per` bullets for each version, in the order given.
  do.call(rbind, lapply(versions, function(v) {
    data.frame(
      Version = v,
      Date = "2026-01-01",
      Category = NA_character_,
      Text = paste0("change ", seq_len(per), " in ", v),
      stringsAsFactors = FALSE
    )
  }))
}

# `news` is a named list of data frames or NULL; names not listed are absent.
# `broken` names are installed on disk but fail to load.
mock_news_helpers <- function(news, broken = character(), env = parent.frame()) {
  testthat::local_mocked_bindings(
    pkg_state = function(pkg) {
      if (pkg %in% broken) "broken" else if (pkg %in% names(news)) "ok" else "absent"
    },
    pkg_news = function(pkg) news[[pkg]],
    .env = env
  )
}

run_news <- function(...) {
  msgs <- character()
  out <- utils::capture.output(
    res <- withCallingHandlers(
      mediationverse_news(...),
      message = function(m) {
        msgs <<- c(msgs, conditionMessage(m))
        invokeRestart("muffleMessage")
      }
    )
  )
  list(res = res, out = out, msgs = msgs)
}

test_that("news() returns a classed long data frame", {
  mock_news_helpers(list(medfit = fake_news(c("0.2.0", "0.1.0"))))
  r <- run_news(n = 1)
  expect_s3_class(r$res, "mediationverse_news")
  expect_s3_class(r$res, "data.frame")
  expect_named(r$res, c("package", "version", "date", "category", "text"))
  expect_true(all(r$res$package == "medfit"))
  expect_true(all(r$res$version == "0.2.0"))
  expect_equal(nrow(r$res), 2L)
})

test_that("news() keeps the n newest versions per package, newest first", {
  mock_news_helpers(list(
    medfit = fake_news(c("0.1.0", "0.3.0", "0.2.0", "0.4.0")),
    RMediation = fake_news(c("1.0.0"))
  ))
  r <- run_news(n = 2)
  med <- r$res[r$res$package == "medfit", ]
  expect_equal(unique(med$version), c("0.4.0", "0.3.0"))
  expect_equal(unique(r$res$version[r$res$package == "RMediation"]), "1.0.0")
})

test_that("news() orders versions numerically (0.10.0 above 0.9.0)", {
  mock_news_helpers(list(medfit = fake_news(c("0.9.0", "0.10.0", "0.2.0"))))
  r <- run_news(n = 2)
  expect_equal(unique(r$res$version), c("0.10.0", "0.9.0"))
})

test_that("news() drops unparseable version headers", {
  mock_news_helpers(list(
    medfit = rbind(
      fake_news("development version"),
      fake_news("0.1.0")
    )
  ))
  r <- run_news(n = 3)
  expect_equal(unique(r$res$version), "0.1.0")
})

test_that("news() reports packages with no NEWS", {
  mock_news_helpers(list(
    medfit = fake_news("0.1.0"),
    probmed = NULL,
    RMediation = fake_news("development version")
  ))
  r <- run_news(n = 1)
  expect_setequal(attr(r$res, "no_news"), c("probmed", "RMediation"))
  expect_false("RMediation" %in% r$res$package)
  expect_match(paste(r$msgs, collapse = "\n"), "No NEWS available")
})

test_that("news() reports absent and broken members", {
  mock_news_helpers(
    list(medfit = fake_news("0.1.0"), probmed = fake_news("0.1.0")),
    broken = "probmed"
  )
  r <- run_news(n = 1)
  expect_equal(attr(r$res, "broken"), "probmed")
  expect_false("probmed" %in% r$res$package)
  expect_true("RMediation" %in% attr(r$res, "not_installed"))
  txt <- paste(r$msgs, collapse = "\n")
  expect_match(txt, "Not installed")
  expect_match(txt, "cannot be loaded")
})

test_that("news() validates n", {
  mock_news_helpers(list())
  for (bad in list(0, -1, 1.5, "a", c(1, 2), NA, NULL)) {
    expect_error(mediationverse_news(n = bad), "whole number")
  }
})

test_that("news() include_self adds mediationverse", {
  mock_news_helpers(list(
    mediationverse = fake_news("0.2.0"),
    medfit = fake_news("0.1.0")
  ))
  with_self <- run_news(n = 1, include_self = TRUE)
  without <- run_news(n = 1)
  expect_true("mediationverse" %in% with_self$res$package)
  expect_false("mediationverse" %in% without$res$package)
})

test_that("news() prints version headings and bullets", {
  mock_news_helpers(list(medfit = fake_news("0.2.0", per = 1)))
  r <- run_news(n = 1)
  txt <- paste(c(r$out, r$msgs), collapse = "\n")
  expect_match(txt, "medfit")
  expect_match(txt, "0.2.0")
  expect_match(txt, "change 1 in 0.2.0")
})

test_that("select_news_versions() ignores rows with NA version", {
  df <- rbind(fake_news("0.1.0"), fake_news("not a version"))
  res <- select_news_versions(df, 5)
  expect_equal(unique(res$Version), "0.1.0")
  expect_equal(nrow(select_news_versions(df[0, ], 3)), 0L)
})
