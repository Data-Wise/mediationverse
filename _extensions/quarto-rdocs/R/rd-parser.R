#' Rd Parser for quarto-rdocs
#'
#' Functions to parse .Rd files and extract documentation components

#' Parse an Rd file and return structured content
#' @param rd_file Path to .Rd file
#' @return List with parsed documentation components
parse_rd_file <- function(rd_file) {
  if (!file.exists(rd_file)) {
    stop("Rd file not found: ", rd_file)
  }

  rd <- tools::parse_Rd(rd_file)

  # Extract components
  list(
    name = extract_rd_tag(rd, "name"),
    alias = extract_rd_tag(rd, "alias", multiple = TRUE),
    title = extract_rd_tag(rd, "title"),
    description = extract_rd_tag(rd, "description"),
    usage = extract_rd_tag(rd, "usage"),
    arguments = extract_rd_arguments(rd),
    details = extract_rd_tag(rd, "details"),
    value = extract_rd_tag(rd, "value"),
    examples = extract_rd_tag(rd, "examples"),
    seealso = extract_rd_tag(rd, "seealso"),
    author = extract_rd_tag(rd, "author"),
    references = extract_rd_tag(rd, "references"),
    note = extract_rd_tag(rd, "note"),
    section = extract_rd_sections(rd),
    keywords = extract_rd_tag(rd, "keyword", multiple = TRUE),
    concept = extract_rd_tag(rd, "concept", multiple = TRUE),
    docType = extract_rd_tag(rd, "docType"),
    format = extract_rd_tag(rd, "format"),
    source = extract_rd_tag(rd, "source")
  )
}

#' Extract a specific tag from parsed Rd
#' @param rd Parsed Rd object
#' @param tag Tag name to extract
#' @param multiple Whether to return multiple values
#' @return Character string or vector
extract_rd_tag <- function(rd, tag, multiple = FALSE) {
  tag_name <- paste0("\\", tag)

  values <- lapply(rd, function(x) {
    if (inherits(x, "Rd") || is.list(x)) {
      tag_attr <- attr(x, "Rd_tag")
      if (!is.null(tag_attr) && tag_attr == tag_name) {
        return(rd_to_text(x))
      }
    }
    NULL
  })

  values <- Filter(Negate(is.null), values)

  if (length(values) == 0) {
    return(NULL)
  }

  if (multiple) {
    unlist(values)
  } else {
    values[[1]]
  }
}

#' Extract arguments from Rd
#' @param rd Parsed Rd object
#' @return Data frame with argument names and descriptions
extract_rd_arguments <- function(rd) {
  args_section <- NULL

  for (x in rd) {
    tag_attr <- attr(x, "Rd_tag")
    if (!is.null(tag_attr) && tag_attr == "\\arguments") {
      args_section <- x
      break
    }
  }

  if (is.null(args_section)) {
    return(data.frame(name = character(), description = character()))
  }

  args <- list()

  for (item in args_section) {
    tag_attr <- attr(item, "Rd_tag")
    if (!is.null(tag_attr) && tag_attr == "\\item") {
      if (length(item) >= 2) {
        arg_name <- rd_to_text(item[[1]])
        arg_desc <- rd_to_text(item[[2]])
        args <- c(args, list(list(name = arg_name, description = arg_desc)))
      }
    }
  }

  if (length(args) == 0) {
    return(data.frame(name = character(), description = character()))
  }

  data.frame(
    name = vapply(args, `[[`, character(1), "name"),
    description = vapply(args, `[[`, character(1), "description"),
    stringsAsFactors = FALSE
  )
}

#' Extract custom sections from Rd
#' @param rd Parsed Rd object
#' @return List of sections with title and content
extract_rd_sections <- function(rd) {
  sections <- list()

  for (x in rd) {
    tag_attr <- attr(x, "Rd_tag")
    if (!is.null(tag_attr) && tag_attr == "\\section") {
      if (length(x) >= 2) {
        title <- rd_to_text(x[[1]])
        content <- rd_to_text(x[[2]])
        sections <- c(sections, list(list(title = title, content = content)))
      }
    }
  }

  sections
}

#' Convert Rd content to plain text/markdown
#' @param rd Rd content (can be nested)
#' @return Character string
rd_to_text <- function(rd) {
  if (is.null(rd)) return("")

  if (is.character(rd)) {
    return(paste(rd, collapse = ""))
  }

  if (!is.list(rd)) {
    return(as.character(rd))
  }

  result <- vapply(rd, function(x) {
    tag <- attr(x, "Rd_tag")

    if (is.null(tag)) {
      if (is.character(x)) {
        return(paste(x, collapse = ""))
      }
      return(rd_to_text(x))
    }

    content <- rd_to_text(x)

    switch(tag,
      "\\code" = paste0("`", content, "`"),
      "\\emph" = paste0("*", content, "*"),
      "\\bold" = paste0("**", content, "**"),
      "\\strong" = paste0("**", content, "**"),
      "\\sQuote" = paste0("'", content, "'"),
      "\\dQuote" = paste0('"', content, '"'),
      "\\link" = paste0("[", content, "](", content, ".qmd)"),
      "\\href" = {
        # href has URL then text
        if (length(x) >= 2) {
          url <- rd_to_text(x[[1]])
          text <- rd_to_text(x[[2]])
          paste0("[", text, "](", url, ")")
        } else {
          content
        }
      },
      "\\url" = paste0("<", content, ">"),
      "\\email" = paste0("<", content, ">"),
      "\\file" = paste0("`", content, "`"),
      "\\pkg" = paste0("**", content, "**"),
      "\\var" = paste0("_", content, "_"),
      "\\env" = paste0("`", content, "`"),
      "\\option" = paste0("`", content, "`"),
      "\\command" = paste0("`", content, "`"),
      "\\dfn" = paste0("*", content, "*"),
      "\\cite" = paste0("(", content, ")"),
      "\\acronym" = content,
      "\\dots" = "...",
      "\\ldots" = "...",
      "\\itemize" = format_itemize(x),
      "\\enumerate" = format_enumerate(x),
      "\\describe" = format_describe(x),
      "\\item" = content,
      "\\cr" = "\n",
      "\\tab" = "\t",
      "RCODE" = content,
      "TEXT" = content,
      "VERB" = content,
      "COMMENT" = "",
      "LIST" = content,
      content
    )
  }, character(1))

  paste(result, collapse = "")
}

#' Format itemize list
format_itemize <- function(rd) {
  items <- vapply(rd, function(x) {
    tag <- attr(x, "Rd_tag")
    if (!is.null(tag) && tag == "\\item") {
      paste0("- ", trimws(rd_to_text(x)))
    } else {
      ""
    }
  }, character(1))

  items <- items[items != ""]
  paste(items, collapse = "\n")
}

#' Format enumerate list
format_enumerate <- function(rd) {
  items <- list()
  for (x in rd) {
    tag <- attr(x, "Rd_tag")
    if (!is.null(tag) && tag == "\\item") {
      items <- c(items, trimws(rd_to_text(x)))
    }
  }

  if (length(items) == 0) return("")

  formatted <- vapply(seq_along(items), function(i) {
    paste0(i, ". ", items[[i]])
  }, character(1))

  paste(formatted, collapse = "\n")
}

#' Format describe list
format_describe <- function(rd) {
  items <- list()

  for (x in rd) {
    tag <- attr(x, "Rd_tag")
    if (!is.null(tag) && tag == "\\item") {
      if (length(x) >= 2) {
        term <- rd_to_text(x[[1]])
        desc <- rd_to_text(x[[2]])
        items <- c(items, list(paste0("**", term, "**: ", desc)))
      }
    }
  }

  paste(unlist(items), collapse = "\n\n")
}

#' Get Rd files for a package
#' @param pkg Package name or path
#' @return Character vector of Rd file paths
get_rd_files <- function(pkg) {
  # Check if pkg is a path to a package directory
  if (dir.exists(pkg)) {
    man_dir <- file.path(pkg, "man")
  } else {
    # Try to find installed package
    pkg_path <- find.package(pkg, quiet = TRUE)
    if (length(pkg_path) == 0) {
      stop("Package not found: ", pkg)
    }
    man_dir <- file.path(pkg_path, "man")
  }

  if (!dir.exists(man_dir)) {
    # For installed packages, .Rd files are in help/
    help_dir <- file.path(pkg_path, "help")
    if (dir.exists(help_dir)) {
      return(list.files(help_dir, pattern = "\\.Rd$", full.names = TRUE))
    }
    return(character(0))
  }

  list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
}

#' Parse package NAMESPACE to get exports
#' @param pkg Package name or path
#' @return Character vector of exported names
get_exports <- function(pkg) {
  if (dir.exists(pkg)) {
    ns_file <- file.path(pkg, "NAMESPACE")
  } else {
    pkg_path <- find.package(pkg, quiet = TRUE)
    if (length(pkg_path) == 0) return(character(0))
    ns_file <- file.path(pkg_path, "NAMESPACE")
  }

  if (!file.exists(ns_file)) {
    return(character(0))
  }

  ns <- readLines(ns_file, warn = FALSE)

  # Extract export() calls
  export_lines <- grep("^export\\(", ns, value = TRUE)
  exports <- gsub("^export\\((.*)\\)$", "\\1", export_lines)
  exports <- unlist(strsplit(exports, ",\\s*"))
  exports <- trimws(exports)

  # Extract exportPattern() calls
  pattern_lines <- grep("^exportPattern\\(", ns, value = TRUE)
  # These are patterns, we'd need to match against actual objects

  exports
}
