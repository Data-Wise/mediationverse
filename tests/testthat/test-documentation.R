test_that("mediationverse_packages() documentation has correct syntax", {
  # Get the path to the help file
  help_path <- system.file("help", "mediationverse.rdb", package = "mediationverse")

  # If help file doesn't exist (during R CMD check before installation),
  # check the source .Rd file
  rd_file <- system.file("..","man", "mediationverse_packages.Rd",
                          package = "mediationverse")

  # Try alternate path for development
  if (!file.exists(rd_file) || file.info(rd_file)$size == 0) {
    # Look for it relative to the test location
    test_dir <- getwd()
    possible_paths <- c(
      file.path(test_dir, "../../man/mediationverse_packages.Rd"),
      file.path(test_dir, "../man/mediationverse_packages.Rd"),
      "man/mediationverse_packages.Rd",
      "../../man/mediationverse_packages.Rd"
    )

    for (path in possible_paths) {
      if (file.exists(path)) {
        rd_file <- path
        break
      }
    }
  }

  # Skip if we still can't find the file
  skip_if_not(file.exists(rd_file), "Cannot find mediationverse_packages.Rd")

  # Read the .Rd file
  rd_content <- readLines(rd_file, warn = FALSE)
  full_content <- paste(rd_content, collapse = "\n")

  # Check for the version line with balanced parentheses
  expect_true(
    grepl("\\\\code\\{version\\}.*Package version.*\\(NA if not installed\\)", full_content),
    label = "Version documentation should have complete parentheses (NA if not installed)"
  )

  # Also check each individual line for balanced parentheses
  for (i in seq_along(rd_content)) {
    line <- rd_content[i]
    if (nchar(line) == 0) next

    # Count parentheses
    open_count <- lengths(regmatches(line, gregexpr("\\(", line)))
    close_count <- lengths(regmatches(line, gregexpr("\\)", line)))

    # Allow for LaTeX commands that might have unbalanced parens across lines
    # But flag obvious issues in \item lines
    if (grepl("\\\\item", line) && grepl("\\(", line)) {
      expect_equal(
        open_count,
        close_count,
        label = sprintf("Line %d should have balanced parentheses: %s", i, line)
      )
    }
  }
})
