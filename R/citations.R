#' Cite the mediationverse Packages
#'
#' @description
#' Collects the citation of each installed mediationverse package in one place,
#' so analyses can cite every package they used. Prints the citations and
#' invisibly returns them.
#'
#' @param style Output style: `"text"` (human-readable, the default) or
#'   `"bibtex"`.
#' @param include_self Logical. Include mediationverse itself? Default is
#'   `FALSE`: the installed copy of the meta-package can be stale, and most
#'   analyses cite the member packages they used.
#'
#' @return Invisibly, a named list of class `mediationverse_citations` with one
#'   citation object per installed package that provides one. Attributes record
#'   the `style`, the packages that are `not_installed`, and the installed
#'   packages with `no_citation`.
#'
#' @details
#' Packages that are not installed are listed in a note. A package whose
#' citation is empty or cannot be built is listed as having no citation
#' available; it never aborts the call. Packages installed from source without
#' a `CITATION` file get an auto-generated citation that can embed a commit
#' hash, which is noted in the output.
#'
#' @examples
#' mediationverse_citations()
#' mediationverse_citations(style = "bibtex")
#'
#' @export
mediationverse_citations <- function(style = c("text", "bibtex"),
                                     include_self = FALSE) {
  style <- match.arg(style)

  pkgs <- if (include_self) mv_all_packages() else mv_core_packages()
  installed <- vapply(pkgs, pkg_installed, logical(1))

  cites <- lapply(pkgs[installed], pkg_citation)
  names(cites) <- pkgs[installed]

  has_citation <- vapply(cites, function(ct) {
    !is.null(ct) && length(ct) > 0
  }, logical(1))

  out <- cites[has_citation]
  attr(out, "style") <- style
  attr(out, "not_installed") <- pkgs[!installed]
  attr(out, "no_citation") <- names(cites)[!has_citation]
  class(out) <- c("mediationverse_citations", "list")

  print(out)
  invisible(out)
}

#' @export
print.mediationverse_citations <- function(x, ...) {
  style <- attr(x, "style")
  if (is.null(style)) style <- "text"

  cli::cli_h1("mediationverse citations")

  has_sha <- FALSE
  for (pkg in names(x)) {
    cli::cli_h2("{pkg}")
    txt <- paste(format(unclass(x)[[pkg]], style = style), collapse = "\n\n")
    cat(txt, "\n", sep = "")
    # format() wraps long lines, so allow any whitespace after "commit".
    if (grepl("commit\\s+[0-9a-f]{7,}", txt)) has_sha <- TRUE
  }

  no_citation <- attr(x, "no_citation")
  if (length(no_citation) > 0) {
    cli::cli_alert_info(
      "No citation available for: {.pkg {no_citation}}"
    )
  }

  not_installed <- attr(x, "not_installed")
  if (length(not_installed) > 0) {
    cli::cli_alert_info("Not installed: {.pkg {not_installed}}")
  }

  if (has_sha) {
    cli::cli_alert_info(
      "Some citations are auto-generated from a source install and embed a commit hash."
    )
  }

  invisible(x)
}

# Citation object for one package, or NULL when it cannot be built.
# Isolated so tests can mock it.
#' @noRd
pkg_citation <- function(pkg) {
  tryCatch(utils::citation(pkg), error = function(e) NULL)
}

# Is the package installed? Isolated so tests can mock it.
#' @noRd
pkg_installed <- function(pkg) {
  requireNamespace(pkg, quietly = TRUE)
}
