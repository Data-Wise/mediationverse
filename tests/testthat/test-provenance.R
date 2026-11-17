# "stats" is always installed, so system.file() succeeds; the DESCRIPTION is
# mocked per case.
with_desc <- function(desc, code) {
  testthat::local_mocked_bindings(
    packageDescription = function(pkg, ...) desc,
    .package = "utils"
  )
  force(code)
}

test_that("pkg_provenance() classifies GitHub installs", {
  with_desc(
    list(RemoteType = "github", RemoteHost = "api.github.com", RemoteSha = "abc"),
    expect_identical(pkg_provenance("stats"), "GitHub")
  )
})

test_that("pkg_provenance() classifies CRAN installs", {
  with_desc(
    list(Repository = "CRAN", RemoteType = "standard"),
    expect_identical(pkg_provenance("stats"), "CRAN")
  )
  with_desc(
    list(RemoteType = "standard", RemoteRepos = "https://cloud.r-project.org/cran"),
    expect_identical(pkg_provenance("stats"), "CRAN")
  )
})

test_that("pkg_provenance() classifies r-universe installs before CRAN", {
  with_desc(
    list(Repository = "https://data-wise.r-universe.dev", RemoteType = "standard"),
    expect_identical(pkg_provenance("stats"), "r-universe")
  )
})

test_that("pkg_provenance() classifies base, local and other installs", {
  with_desc(list(Priority = "base"), expect_identical(pkg_provenance("stats"), "base"))
  with_desc(list(Built = "R 4.6.0"), expect_identical(pkg_provenance("stats"), "local"))
  with_desc(
    list(RemoteType = "git", RemoteUrl = "https://example.org/x.git"),
    expect_identical(pkg_provenance("stats"), "other")
  )
})

test_that("pkg_provenance() is NA for absent packages and unreadable descriptions", {
  expect_identical(pkg_provenance("notapackage.zzz"), NA_character_)
  with_desc(NA, expect_identical(pkg_provenance("stats"), NA_character_))
})

test_that("pkg_provenance() reads a real install", {
  # Positive control against an unmocked DESCRIPTION: stats is a base package.
  expect_identical(pkg_provenance("stats"), "base")
})
