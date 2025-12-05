test_that("roxygen2 documentation has complete syntax", {
  # Read the source file (relative to package root)
  source_file <- testthat::test_path("../../R/packages.R")

  lines <- readLines(source_file, warn = FALSE)

  # Find roxygen2 comment lines
  roxygen_lines <- grep("^#'", lines, value = TRUE)

  # Check for balanced parentheses in each roxygen line
  for (i in seq_along(roxygen_lines)) {
    line <- roxygen_lines[i]

    # Count opening and closing parentheses
    open_count <- length(gregexpr("\\(", line)[[1]])
    close_count <- length(gregexpr("\\)", line)[[1]])

    # Adjust for no matches (gregexpr returns -1)
    if (open_count == 1 && gregexpr("\\(", line)[[1]][1] == -1) open_count <- 0
    if (close_count == 1 && gregexpr("\\)", line)[[1]][1] == -1) close_count <- 0

    expect_equal(
      open_count,
      close_count,
      label = sprintf("Parentheses balanced in roxygen line %d: %s", i, line)
    )
  }
})

test_that("mediationverse_packages() documentation is complete", {
  # Check that the generated .Rd file has proper syntax
  rd_file <- "man/mediationverse_packages.Rd"

  if (file.exists(rd_file)) {
    rd_content <- readLines(rd_file, warn = FALSE)

    # Find the version line specifically
    version_line <- grep("version.*Package version", rd_content, value = TRUE)

    if (length(version_line) > 0) {
      # Check that parentheses are balanced
      open_count <- length(gregexpr("\\(", version_line)[[1]])
      close_count <- length(gregexpr("\\)", version_line)[[1]])

      # Adjust for no matches
      if (open_count == 1 && gregexpr("\\(", version_line)[[1]][1] == -1) open_count <- 0
      if (close_count == 1 && gregexpr("\\)", version_line)[[1]][1] == -1) close_count <- 0

      expect_equal(
        open_count,
        close_count,
        label = "Version documentation should have balanced parentheses"
      )
    }
  } else {
    skip("Generated .Rd file not found")
  }
})
