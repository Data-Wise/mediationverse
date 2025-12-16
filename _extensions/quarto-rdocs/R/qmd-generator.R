#' Qmd Generator for quarto-rdocs
#'
#' Functions to generate Quarto markdown from parsed Rd content

#' Convert parsed Rd to Quarto markdown
#' @param parsed List from parse_rd_file()
#' @param options List of rendering options
#' @return Character string of Quarto markdown
rd_to_qmd <- function(parsed, options = list()) {
  # Default options
  opts <- list(
    eval_examples = FALSE,
    freeze = TRUE,
    source_link = NULL,
    package = NULL
  )
  opts[names(options)] <- options

  lines <- character(0)

  # YAML frontmatter
  lines <- c(lines, "---")
  lines <- c(lines, paste0('title: "', escape_yaml(parsed$name %||% "Unknown"), '"'))

  if (!is.null(parsed$title)) {
    lines <- c(lines, paste0('description: "', escape_yaml(parsed$title), '"'))
  }

  # Add categories from keywords
  if (!is.null(parsed$keywords) && length(parsed$keywords) > 0) {
    lines <- c(lines, "categories:")
    for (kw in parsed$keywords) {
      lines <- c(lines, paste0("  - ", kw))
    }
  }

  lines <- c(lines, "---")
  lines <- c(lines, "")

  # Title section (function signature style)
  if (!is.null(parsed$name)) {
    lines <- c(lines, paste0("# ", parsed$name, " {.function-name}"))
    lines <- c(lines, "")
  }

  # Description
  if (!is.null(parsed$description)) {
    lines <- c(lines, clean_text(parsed$description))
    lines <- c(lines, "")
  }

  # Usage
  if (!is.null(parsed$usage)) {
    lines <- c(lines, "## Usage")
    lines <- c(lines, "")
    lines <- c(lines, "```r")
    lines <- c(lines, clean_code(parsed$usage))
    lines <- c(lines, "```")
    lines <- c(lines, "")
  }

  # Arguments
  if (!is.null(parsed$arguments) && nrow(parsed$arguments) > 0) {
    lines <- c(lines, "## Arguments")
    lines <- c(lines, "")
    lines <- c(lines, "| Argument | Description |")
    lines <- c(lines, "|:---------|:------------|")
    for (i in seq_len(nrow(parsed$arguments))) {
      arg_name <- paste0("`", parsed$arguments$name[i], "`")
      arg_desc <- gsub("\\|", "\\\\|", parsed$arguments$description[i])
      arg_desc <- gsub("\n", " ", arg_desc)
      lines <- c(lines, paste0("| ", arg_name, " | ", arg_desc, " |"))
    }
    lines <- c(lines, "")
  }

  # Details
  if (!is.null(parsed$details)) {
    lines <- c(lines, "## Details")
    lines <- c(lines, "")
    lines <- c(lines, clean_text(parsed$details))
    lines <- c(lines, "")
  }

  # Value
  if (!is.null(parsed$value)) {
    lines <- c(lines, "## Value")
    lines <- c(lines, "")
    lines <- c(lines, clean_text(parsed$value))
    lines <- c(lines, "")
  }

  # Custom sections
  if (length(parsed$section) > 0) {
    for (sec in parsed$section) {
      lines <- c(lines, paste0("## ", sec$title))
      lines <- c(lines, "")
      lines <- c(lines, clean_text(sec$content))
      lines <- c(lines, "")
    }
  }

  # Note
  if (!is.null(parsed$note)) {
    lines <- c(lines, "::: {.callout-note}")
    lines <- c(lines, clean_text(parsed$note))
    lines <- c(lines, ":::")
    lines <- c(lines, "")
  }

  # References
  if (!is.null(parsed$references)) {
    lines <- c(lines, "## References")
    lines <- c(lines, "")
    lines <- c(lines, clean_text(parsed$references))
    lines <- c(lines, "")
  }

  # See Also
  if (!is.null(parsed$seealso)) {
    lines <- c(lines, "## See Also")
    lines <- c(lines, "")
    lines <- c(lines, clean_text(parsed$seealso))
    lines <- c(lines, "")
  }

  # Examples
  if (!is.null(parsed$examples)) {
    lines <- c(lines, "## Examples")
    lines <- c(lines, "")

    example_code <- clean_code(parsed$examples)

    if (opts$eval_examples) {
      # Evaluated code block
      lines <- c(lines, "```{r}")
      if (opts$freeze) {
        lines <- c(lines, "#| freeze: true")
      }
      lines <- c(lines, "#| warning: false")
      lines <- c(lines, example_code)
      lines <- c(lines, "```")
    } else {
      # Static code block
      lines <- c(lines, "```r")
      lines <- c(lines, example_code)
      lines <- c(lines, "```")
    }
    lines <- c(lines, "")
  }

  # Source link
  if (!is.null(opts$source_link)) {
    lines <- c(lines, "---")
    lines <- c(lines, "")
    lines <- c(lines, paste0("[View source on GitHub](", opts$source_link, ")"))
    lines <- c(lines, "")
  }

  # Author
  if (!is.null(parsed$author)) {
    lines <- c(lines, "---")
    lines <- c(lines, "")
    lines <- c(lines, paste0("*Author: ", clean_text(parsed$author), "*"))
    lines <- c(lines, "")
  }

  paste(lines, collapse = "\n")
}

#' Generate reference index page
#' @param functions List of function info (name, title, file)
#' @param sections Section definitions from config
#' @param package Package name
#' @return Character string of Quarto markdown
generate_index_qmd <- function(functions, sections = NULL, package = NULL) {
  lines <- character(0)

  # YAML frontmatter
  lines <- c(lines, "---")
  lines <- c(lines, 'title: "Function Reference"')
  if (!is.null(package)) {
    lines <- c(lines, paste0('description: "API documentation for ', package, '"'))
  }
  lines <- c(lines, "listing:")
  lines <- c(lines, "  - id: functions")
  lines <- c(lines, "    contents: '*.qmd'")
  lines <- c(lines, "    type: table")
  lines <- c(lines, "    fields: [title, description]")
  lines <- c(lines, "    sort: title")
  lines <- c(lines, "    filter-ui: true")
  lines <- c(lines, "    sort-ui: true")
  lines <- c(lines, "---")
  lines <- c(lines, "")

  if (!is.null(package)) {
    lines <- c(lines, paste0("# ", package, " Reference"))
    lines <- c(lines, "")
  }

  if (!is.null(sections) && length(sections) > 0) {
    # Organized by sections
    for (sec in sections) {
      lines <- c(lines, paste0("## ", sec$title))
      lines <- c(lines, "")

      if (!is.null(sec$desc)) {
        lines <- c(lines, sec$desc)
        lines <- c(lines, "")
      }

      # Get functions in this section
      sec_funcs <- functions[functions$section == sec$title, ]

      if (nrow(sec_funcs) > 0) {
        lines <- c(lines, "| Function | Description |")
        lines <- c(lines, "|:---------|:------------|")
        for (i in seq_len(nrow(sec_funcs))) {
          fn_link <- paste0("[", sec_funcs$name[i], "](", sec_funcs$file[i], ")")
          fn_desc <- sec_funcs$title[i] %||% ""
          lines <- c(lines, paste0("| ", fn_link, " | ", fn_desc, " |"))
        }
        lines <- c(lines, "")
      }
    }
  } else {
    # Simple listing
    lines <- c(lines, ":::{#functions}")
    lines <- c(lines, ":::")
  }

  paste(lines, collapse = "\n")
}

#' Generate sidebar YAML for reference section
#' @param functions Data frame of function info
#' @param sections Section definitions
#' @param ref_dir Reference directory name
#' @return Character string of YAML
generate_sidebar_yml <- function(functions, sections = NULL, ref_dir = "reference") {
  lines <- character(0)

  lines <- c(lines, "website:")
  lines <- c(lines, "  sidebar:")
  lines <- c(lines, "    - id: reference")
  lines <- c(lines, '      title: "Reference"')
  lines <- c(lines, "      style: docked")
  lines <- c(lines, "      collapse-level: 2")
  lines <- c(lines, "      contents:")
  lines <- c(lines, paste0('        - text: "Index"'))
  lines <- c(lines, paste0('          file: ', ref_dir, '/index.qmd'))

  if (!is.null(sections) && length(sections) > 0) {
    for (sec in sections) {
      lines <- c(lines, paste0('        - section: "', sec$title, '"'))
      lines <- c(lines, "          contents:")

      sec_funcs <- functions[functions$section == sec$title, ]
      for (i in seq_len(nrow(sec_funcs))) {
        lines <- c(lines, paste0('            - ', ref_dir, '/', sec_funcs$file[i]))
      }
    }
  } else {
    # All functions flat
    for (i in seq_len(nrow(functions))) {
      lines <- c(lines, paste0('        - ', ref_dir, '/', functions$file[i]))
    }
  }

  paste(lines, collapse = "\n")
}

#' Escape special characters for YAML
escape_yaml <- function(x) {
  if (is.null(x)) return("")
  x <- gsub('"', '\\"', x)
  x <- gsub("\n", " ", x)
  trimws(x)
}

#' Clean text for markdown output
clean_text <- function(x) {
  if (is.null(x)) return("")
  x <- trimws(x)
  # Remove excessive whitespace
  x <- gsub("[ \t]+", " ", x)
  # But preserve intentional line breaks
  x <- gsub("\n[ \t]+", "\n", x)
  x
}

#' Clean code blocks
clean_code <- function(x) {
  if (is.null(x)) return("")
  x <- trimws(x)
  # Remove \dontrun{} wrappers but keep content
  x <- gsub("\\\\dontrun\\{([^}]*)\\}", "# Not run:\n\\1", x)
  # Remove \donttest{} wrappers
  x <- gsub("\\\\donttest\\{([^}]*)\\}", "\\1", x)
  # Remove \dontshow{} completely
  x <- gsub("\\\\dontshow\\{[^}]*\\}", "", x)
  x
}

#' Null coalescing operator
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
