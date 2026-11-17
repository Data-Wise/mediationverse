test_that("parse_remote_version() reads a flat JSON Version field", {
  expect_equal(parse_remote_version('{"Package":"medfit","Version":"0.18.0"}'), "0.18.0")
  expect_equal(parse_remote_version('{"Version" : "1.6.1", "x": 1}'), "1.6.1")
  expect_equal(parse_remote_version('{"_id":"a","Version":"0.6.0.9000"}'), "0.6.0.9000")
})

test_that("parse_remote_version() returns NA for anything else", {
  expect_true(is.na(parse_remote_version("")))
  expect_true(is.na(parse_remote_version(NA_character_)))
  expect_true(is.na(parse_remote_version('{"Package":"x"}')))
  expect_true(is.na(parse_remote_version("<html>nope</html>")))
  expect_true(is.na(parse_remote_version('{"Version":"not a version"}')))
})

test_that("pkg_latest() asks CRAN for CRAN members and r-universe for GitHub members", {
  urls <- character()
  testthat::local_mocked_bindings(
    read_remote = function(url) {
      urls <<- c(urls, url)
      '{"Version":"9.9.9"}'
    }
  )
  expect_equal(pkg_latest("RMediation", "CRAN"), "9.9.9")
  expect_equal(pkg_latest("medfit", "GitHub"), "9.9.9")
  expect_match(urls[1], "^https://crandb\\.r-pkg\\.org/RMediation$")
  expect_match(urls[2], "^https://data-wise\\.r-universe\\.dev/api/packages/medfit$")
})

test_that("pkg_latest() returns NA when the lookup fails or is malformed", {
  testthat::local_mocked_bindings(read_remote = function(url) NA_character_)
  expect_true(is.na(pkg_latest("medfit", "GitHub")))
  testthat::local_mocked_bindings(read_remote = function(url) "garbage")
  expect_true(is.na(pkg_latest("medfit", "GitHub")))
})

test_that("pkg_latest() never builds a URL for a name outside the registry", {
  testthat::local_mocked_bindings(
    read_remote = function(url) stop("must not be called")
  )
  expect_true(is.na(pkg_latest("not-a-member", "GitHub")))
  expect_true(is.na(pkg_latest("../etc/passwd", "CRAN")))
  expect_true(is.na(pkg_latest("medfit", "elsewhere")))
})

test_that("read_remote() returns NA on a failing connection and restores the timeout", {
  old <- getOption("timeout")
  testthat::local_mocked_bindings(
    url = function(...) stop("offline"),
    .package = "base"
  )
  expect_true(is.na(read_remote("https://example.invalid/x")))
  expect_equal(getOption("timeout"), old)
})

test_that("read_remote() joins the lines of a successful read", {
  testthat::local_mocked_bindings(
    url = function(...) textConnection('{"Version":'),
    readLines = function(con, ...) c('{"Version":', '"1.0.0"}'),
    .package = "base"
  )
  expect_equal(read_remote("https://example.invalid/x"), '{"Version": "1.0.0"}')
})
