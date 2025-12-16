#!/usr/bin/env Rscript
#' Test script for quarto-rdocs extension
#'
#' Run from package root:
#'   Rscript _extensions/quarto-rdocs/test/test-rdocs.R

library(testthat)

# Get paths
pkg_root <- getwd()
ext_root <- file.path(pkg_root, "_extensions/quarto-rdocs")

# Source the functions
source(file.path(ext_root, "R/rd-parser.R"))
source(file.path(ext_root, "R/qmd-generator.R"))

test_that("parse_rd_file works", {
  rd_file <- file.path(pkg_root, "man/mediationverse_packages.Rd")
  skip_if_not(file.exists(rd_file), "No .Rd file to test")

  parsed <- parse_rd_file(rd_file)

  expect_type(parsed, "list")
  expect_equal(parsed$name, "mediationverse_packages")
  expect_true(nchar(parsed$title) > 0)
  expect_true(nrow(parsed$arguments) > 0)
})

test_that("rd_to_qmd generates valid markdown", {
  rd_file <- file.path(pkg_root, "man/mediationverse_packages.Rd")
  skip_if_not(file.exists(rd_file), "No .Rd file to test")

  parsed <- parse_rd_file(rd_file)
  qmd <- rd_to_qmd(parsed)

  # Should have YAML frontmatter

  expect_true(grepl("^---", qmd))
  expect_true(grepl("title:", qmd))

  # Should have sections
  expect_true(grepl("## Usage", qmd))
  expect_true(grepl("## Arguments", qmd))

  # Should have code blocks
  expect_true(grepl("```r", qmd))
})

test_that("get_exports parses NAMESPACE", {
  skip_if_not(file.exists(file.path(pkg_root, "NAMESPACE")))

  exports <- get_exports(pkg_root)

  expect_type(exports, "character")
  expect_true(length(exports) > 0)
  expect_true("mediationverse_packages" %in% exports)
})

test_that("get_rd_files finds .Rd files", {
  rd_files <- get_rd_files(pkg_root)

  expect_type(rd_files, "character")
  expect_true(length(rd_files) > 0)
  expect_true(all(grepl("\\.Rd$", rd_files)))
})

test_that("generate_index_qmd creates valid index", {
  functions <- data.frame(
    name = c("func1", "func2"),
    title = c("Title 1", "Title 2"),
    file = c("func1.qmd", "func2.qmd"),
    section = c("Section A", "Section A"),
    stringsAsFactors = FALSE
  )

  sections <- list(
    list(title = "Section A", desc = "Description")
  )

  index <- generate_index_qmd(functions, sections, "testpkg")

  expect_true(grepl("^---", index))
  expect_true(grepl("## Section A", index))
  expect_true(grepl("func1", index))
})

test_that("generate_sidebar_yml creates valid YAML", {
  functions <- data.frame(
    name = c("func1", "func2"),
    title = c("Title 1", "Title 2"),
    file = c("func1.qmd", "func2.qmd"),
    section = c("Section A", "Section A"),
    stringsAsFactors = FALSE
  )

  sidebar <- generate_sidebar_yml(functions, NULL, "reference")

  expect_true(grepl("website:", sidebar))
  expect_true(grepl("sidebar:", sidebar))
  expect_true(grepl("reference/func1.qmd", sidebar))
})

test_that("resolve_contents handles patterns", {
  exports <- c("calc_mean", "calc_sd", "plot_data", "helper_internal")
  rd_files <- character(0)  # Not needed for this test

  # Test starts_with
  result <- resolve_contents(list('starts_with("calc_")'), exports, rd_files)
  expect_equal(sort(result), c("calc_mean", "calc_sd"))

  # Test ends_with
  result <- resolve_contents(list('ends_with("_data")'), exports, rd_files)
  expect_equal(result, "plot_data")

  # Test exclusion
  result <- resolve_contents(list("calc_mean", "-calc_mean"), exports, rd_files)
  expect_equal(result, character(0))
})

cat("\n✓ All tests passed!\n")
