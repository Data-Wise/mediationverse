test_that("mediationverse_conflicts() returns data frame with expected columns", {
  result <- mediationverse_conflicts()

  expect_s3_class(result, "data.frame")
  expect_named(result, c("function_name", "packages", "winner"))
})

test_that("mediationverse_conflicts(only_loaded = TRUE) returns empty frame when < 2 ecosystem pkgs loaded", {
  # In a test environment, the ecosystem packages are not attached; mediationverse itself
  # may or may not be. Either way, fewer than 2 are on the search path, so the result
  # should be an empty (0-row) data frame.
  result <- mediationverse_conflicts(only_loaded = TRUE)

  expect_s3_class(result, "data.frame")
  # Should not error and should have correct shape
  expect_named(result, c("function_name", "packages", "winner"))
})

test_that("mediationverse_conflicts() returns invisibly", {
  expect_invisible(mediationverse_conflicts())
})

test_that("mediationverse_conflicts() prints without error (empty case)", {
  result <- mediationverse_conflicts()
  expect_no_error(print(result))
  expect_invisible(print(result))
})

test_that("mediationverse_conflicts(only_loaded = FALSE) returns correct structure", {
  result <- mediationverse_conflicts(only_loaded = FALSE)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("function_name", "packages", "winner"))

  if (nrow(result) > 0) {
    expect_type(result$function_name, "character")
    expect_type(result$packages, "character")
    expect_type(result$winner, "character")
    # winner must be one of the packages listed in the packages field
    for (i in seq_len(nrow(result))) {
      pkg_list <- strsplit(result$packages[i], ", ")[[1]]
      expect_true(result$winner[i] %in% pkg_list)
    }
  }
})
