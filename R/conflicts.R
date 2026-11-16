#' Show mediationverse Conflicts
#'
#' @description
#' Identifies functions that are exported by multiple mediationverse packages,
#' which could lead to masking issues.
#'
#' @param only_loaded Logical. Only check currently loaded packages?
#'   Default is TRUE.
#'
#' @return A data frame with columns:
#'   - `function_name`: Name of the conflicting function
#'   - `packages`: Character vector of packages exporting this function
#'   - `winner`: The package whose version will be used (last loaded)
#'
#' @details
#' When multiple packages export a function with the same name, R uses the
#' version from the package that was loaded last. This function helps identify
#' such conflicts so you can use explicit namespacing (e.g., `medfit::extract_mediation()`)
#' when needed.
#'
#' @examples
#' \dontrun{
#' # Show conflicts among loaded mediationverse packages
#' mediationverse_conflicts()
#' }
#'
#' @export
mediationverse_conflicts <- function(only_loaded = TRUE) {
  core <- mv_core_packages()

  if (only_loaded) {
    # Only check packages that are attached
    core <- core[vapply(core, function(pkg) {
      paste0("package:", pkg) %in% search()
    }, logical(1))]
  } else {
    # Check all installed packages
    core <- core[vapply(core, function(pkg) {
      requireNamespace(pkg, quietly = TRUE)
    }, logical(1))]
  }

  if (length(core) < 2) {
    if (requireNamespace("cli", quietly = TRUE)) {
      cli::cli_alert_info("No conflicts possible with fewer than 2 packages loaded.")
    } else {
      message("No conflicts possible with fewer than 2 packages loaded.")
    }
    return(invisible(data.frame(
      function_name = character(0),
      packages = character(0),
      winner = character(0),
      stringsAsFactors = FALSE
    )))
  }

  conflicts <- find_conflicts(core)
  # Lookup failures are only for internal callers such as the sitrep checks.
  attr(conflicts, "failed_lookup") <- NULL

  if (nrow(conflicts) == 0) {
    if (requireNamespace("cli", quietly = TRUE)) {
      cli::cli_alert_success("No conflicts found among mediationverse packages!")
    } else {
      message("No conflicts found among mediationverse packages!")
    }
    return(invisible(conflicts))
  }

  class(conflicts) <- c("mediationverse_conflicts", "data.frame")
  conflicts
}

# Quiet conflict finder: no messages, no classing. Returns a data frame with
# columns `function_name`, `packages` and `winner`; zero rows when fewer than
# two packages are given or nothing conflicts. The "failed_lookup" attribute
# lists packages whose exports could not be read (an incomplete inspection,
# not "no conflict"). Used by
# mediationverse_conflicts() and by the sitrep checks.
#' @noRd
find_conflicts <- function(pkgs) {
  failed <- character(0)

  finish <- function(df) {
    attr(df, "failed_lookup") <- failed
    df
  }

  empty <- data.frame(
    function_name = character(0),
    packages = character(0),
    winner = character(0),
    stringsAsFactors = FALSE
  )

  if (length(pkgs) < 2) {
    return(finish(empty))
  }

  # Get exports from each package, remembering lookups that failed
  pkg_exports <- lapply(pkgs, function(pkg) {
    tryCatch(
      getNamespaceExports(pkg),
      error = function(e) {
        failed <<- c(failed, pkg)
        character(0)
      }
    )
  })
  names(pkg_exports) <- pkgs

  # Drop S4/S7 method-table internals (".__T__...", ".__C__..."); they are
  # not user-facing functions and always look like conflicts.
  pkg_exports <- lapply(pkg_exports, function(exports) {
    exports[!startsWith(exports, ".__")]
  })

  # Find all unique function names
  all_funs <- unique(unlist(pkg_exports))

  # Find functions exported by multiple packages
  conflicts <- list()
  for (fun in all_funs) {
    pkgs_with_fun <- pkgs[vapply(pkg_exports, function(exports) {
      fun %in% exports
    }, logical(1))]

    if (length(pkgs_with_fun) > 1) {
      conflicts[[fun]] <- pkgs_with_fun
    }
  }

  if (length(conflicts) == 0) {
    return(finish(empty))
  }

  # Determine which package "wins" (last in search path)
  search_order <- rev(search())

  finish(data.frame(
    function_name = names(conflicts),
    packages = vapply(conflicts, paste, character(1), collapse = ", "),
    winner = vapply(conflicts, function(p) {
      pkg_positions <- vapply(p, function(x) {
        pos <- which(search_order == paste0("package:", x))
        if (length(pos) == 0) Inf else pos
      }, numeric(1))
      p[which.min(pkg_positions)]
    }, character(1)),
    row.names = NULL,
    stringsAsFactors = FALSE
  ))
}

#' @export
print.mediationverse_conflicts <- function(x, ...) {
  if (nrow(x) == 0) {
    if (requireNamespace("cli", quietly = TRUE)) {
      cli::cli_alert_success("No conflicts found!")
    } else {
      message("No conflicts found!")
    }
    return(invisible(x))
  }

  if (requireNamespace("cli", quietly = TRUE)) {
    cli::cli_h1("mediationverse conflicts")
    cli::cli_text("{nrow(x)} conflict{?s} found:")
    cli::cli_text("")

    for (i in seq_len(nrow(x))) {
      cli::cli_text(
        "{.fn {x$function_name[i]}} from {.pkg {x$packages[i]}} ",
        "{.emph (using {x$winner[i]})}"
      )
    }

    cli::cli_text("")
    cli::cli_alert_info("Use {.code package::function()} to call a specific version")
  } else {
    cat("mediationverse conflicts\n")
    cat(strrep("-", 50), "\n")
    cat(sprintf("%d conflict(s) found:\n\n", nrow(x)))

    for (i in seq_len(nrow(x))) {
      cat(sprintf(
        "  %s() from [%s] (using %s)\n",
        x$function_name[i], x$packages[i], x$winner[i]
      ))
    }

    cat("\nUse package::function() to call a specific version\n")
  }

  invisible(x)
}
