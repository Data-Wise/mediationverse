#!/usr/bin/env Rscript
#' quarto-rdocs Pre-render Script
#'
#' This script is called by Quarto before rendering to generate
#' reference documentation from R package .Rd files.

# Get the extension directory
ext_dir <- Sys.getenv("QUARTO_PROJECT_DIR", ".")
if (ext_dir == ".") ext_dir <- getwd()

# Source helper functions
source(file.path(ext_dir, "_extensions/quarto-rdocs/R/rd-parser.R"))
source(file.path(ext_dir, "_extensions/quarto-rdocs/R/qmd-generator.R"))

#' Main entry point
main <- function() {
  message("quarto-rdocs: Starting documentation generation...")


  # Read _quarto.yml
  quarto_yml <- file.path(ext_dir, "_quarto.yml")
  if (!file.exists(quarto_yml)) {
    stop("_quarto.yml not found in project directory")
  }

  config <- yaml::read_yaml(quarto_yml)
  rdocs_config <- config$rdocs

  if (is.null(rdocs_config)) {
    message("quarto-rdocs: No 'rdocs' section in _quarto.yml, skipping")
    return(invisible(NULL))
  }

  # Get configuration
  pkg <- rdocs_config$package %||% basename(ext_dir)
  ref_dir <- rdocs_config$dir %||% "reference"
  sidebar_file <- rdocs_config$sidebar %||% file.path(ref_dir, "_sidebar.yml")
  sections <- rdocs_config$sections %||% list()

  options <- list(
    eval_examples = rdocs_config$options$examples %||% FALSE,
    freeze = rdocs_config$options$freeze %||% TRUE,
    source_links = rdocs_config$options$source_links %||% FALSE,
    repo_url = rdocs_config$options$repo_url %||% NULL
  )

  message("quarto-rdocs: Package = ", pkg)
  message("quarto-rdocs: Output directory = ", ref_dir)


  # Create output directory
  ref_path <- file.path(ext_dir, ref_dir)
  if (!dir.exists(ref_path)) {
    dir.create(ref_path, recursive = TRUE)
  }

  # Get all .Rd files
  rd_files <- get_rd_files(ext_dir)  # Use local package

  if (length(rd_files) == 0) {
    message("quarto-rdocs: No .Rd files found in man/")
    return(invisible(NULL))
  }

  message("quarto-rdocs: Found ", length(rd_files), " .Rd files")

  # Get exports to filter internal functions
  exports <- get_exports(ext_dir)
  message("quarto-rdocs: Found ", length(exports), " exported functions")

  # Build function registry
  functions <- data.frame(
    name = character(),
    title = character(),
    file = character(),
    section = character(),
    stringsAsFactors = FALSE
  )

  # Determine which functions to document based on sections
  if (length(sections) > 0) {
    # Use section-based selection
    for (sec in sections) {
      contents <- resolve_contents(sec$contents, exports, rd_files)
      for (fn_name in contents) {
        rd_file <- find_rd_for_function(fn_name, rd_files)
        if (!is.null(rd_file)) {
          result <- process_rd_file(rd_file, fn_name, ref_path, options, sec$title)
          if (!is.null(result)) {
            functions <- rbind(functions, result)
          }
        }
      }
    }
  } else {
    # Document all exports
    for (fn_name in exports) {
      rd_file <- find_rd_for_function(fn_name, rd_files)
      if (!is.null(rd_file)) {
        result <- process_rd_file(rd_file, fn_name, ref_path, options, "Functions")
        if (!is.null(result)) {
          functions <- rbind(functions, result)
        }
      }
    }
  }

  message("quarto-rdocs: Generated ", nrow(functions), " documentation pages")

  # Generate index page
  index_qmd <- generate_index_qmd(functions, sections, pkg)
  writeLines(index_qmd, file.path(ref_path, "index.qmd"))
  message("quarto-rdocs: Generated index.qmd")

  # Generate sidebar
  sidebar_yml <- generate_sidebar_yml(functions, sections, ref_dir)
  sidebar_path <- file.path(ext_dir, sidebar_file)
  sidebar_dir <- dirname(sidebar_path)
  if (!dir.exists(sidebar_dir)) {
    dir.create(sidebar_dir, recursive = TRUE)
  }
  writeLines(sidebar_yml, sidebar_path)
  message("quarto-rdocs: Generated ", sidebar_file)

  message("quarto-rdocs: Documentation generation complete!")
  invisible(functions)
}

#' Process a single .Rd file
process_rd_file <- function(rd_file, fn_name, ref_path, options, section) {
  tryCatch({
    parsed <- parse_rd_file(rd_file)

    # Generate source link if enabled
    if (options$source_links && !is.null(options$repo_url)) {
      # Try to find the source file
      options$source_link <- paste0(options$repo_url, "/blob/main/R/", fn_name, ".R")
    }

    qmd_content <- rd_to_qmd(parsed, options)
    qmd_file <- paste0(fn_name, ".qmd")
    writeLines(qmd_content, file.path(ref_path, qmd_file))

    data.frame(
      name = fn_name,
      title = parsed$title %||% fn_name,
      file = qmd_file,
      section = section,
      stringsAsFactors = FALSE
    )
  }, error = function(e) {
    warning("quarto-rdocs: Error processing ", rd_file, ": ", e$message)
    NULL
  })
}

#' Find .Rd file for a function name
find_rd_for_function <- function(fn_name, rd_files) {
  # Try exact match first
  exact <- grep(paste0("/", fn_name, "\\.Rd$"), rd_files, value = TRUE)
  if (length(exact) > 0) return(exact[1])

  # Try case-insensitive
  lower <- grep(paste0("/", tolower(fn_name), "\\.Rd$"), tolower(rd_files))
  if (length(lower) > 0) return(rd_files[lower[1]])

  # Search inside .Rd files for alias
  for (rd_file in rd_files) {
    rd <- tools::parse_Rd(rd_file)
    aliases <- extract_rd_tag(rd, "alias", multiple = TRUE)
    if (fn_name %in% aliases) {
      return(rd_file)
    }
  }

  NULL
}

#' Resolve contents selectors to function names
resolve_contents <- function(contents, exports, rd_files) {
  if (is.null(contents)) return(exports)

  result <- character()

  for (item in contents) {
    if (is.character(item)) {
      if (startsWith(item, "-")) {
        # Exclusion
        exclude <- substring(item, 2)
        result <- setdiff(result, exclude)
      } else if (startsWith(item, "starts_with(")) {
        # Pattern: starts_with("prefix")
        prefix <- gsub('starts_with\\(["\']([^"\']+)["\']\\)', "\\1", item)
        matches <- grep(paste0("^", prefix), exports, value = TRUE)
        result <- c(result, matches)
      } else if (startsWith(item, "ends_with(")) {
        # Pattern: ends_with("suffix")
        suffix <- gsub('ends_with\\(["\']([^"\']+)["\']\\)', "\\1", item)
        matches <- grep(paste0(suffix, "$"), exports, value = TRUE)
        result <- c(result, matches)
      } else if (startsWith(item, "matches(")) {
        # Pattern: matches("regex")
        pattern <- gsub('matches\\(["\']([^"\']+)["\']\\)', "\\1", item)
        matches <- grep(pattern, exports, value = TRUE)
        result <- c(result, matches)
      } else if (startsWith(item, "has_concept(")) {
        # Pattern: has_concept("concept")
        # Would need to parse .Rd files for @concept tags
        concept <- gsub('has_concept\\(["\']([^"\']+)["\']\\)', "\\1", item)
        # TODO: Implement concept matching
        warning("has_concept() not yet implemented")
      } else {
        # Exact function name
        if (item %in% exports) {
          result <- c(result, item)
        } else {
          # Check if it exists as an .Rd file anyway (might be documented but not exported)
          rd_match <- find_rd_for_function(item, rd_files)
          if (!is.null(rd_match)) {
            result <- c(result, item)
          } else {
            warning("quarto-rdocs: Function '", item, "' not found in exports or .Rd files")
          }
        }
      }
    }
  }

  unique(result)
}

#' Null coalescing operator
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

# Run main
if (!interactive()) {
  main()
}
