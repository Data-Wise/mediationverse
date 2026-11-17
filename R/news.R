#' Recent News from the mediationverse Packages
#'
#' @description
#' Collects the latest NEWS entries of each installed mediationverse package in
#' one place, so a change in any member is easy to spot. Prints the entries and
#' invisibly returns them.
#'
#' @param n Number of most recent released versions to show per package: a
#'   single whole number >= 1. Default is `3`.
#' @param include_self Logical. Include mediationverse itself? Default is
#'   `FALSE`, matching [mediationverse_citations()].
#'
#' @return Invisibly, a long data frame of class `mediationverse_news` with
#'   one row per NEWS bullet and columns `package`, `version`, `date`,
#'   `category` and `text`. Attributes record the packages that are
#'   `not_installed`, the installed packages that cannot be loaded (`broken`),
#'   and the installed packages with `no_news`.
#'
#' @details
#' `n` counts released versions, not bullets. Versions are ordered numerically
#' (0.10.0 is newer than 0.9.0); headings that are not version numbers, such as
#' "development version", are ignored. A package with no usable NEWS is listed
#' in a note and never aborts the call.
#'
#' @examples
#' mediationverse_news()
#' mediationverse_news(n = 1)
#'
#' @export
mediationverse_news <- function(n = 3L, include_self = FALSE) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 1 || n != round(n)) {
    cli::cli_abort("{.arg n} must be a single whole number >= 1.")
  }

  pkgs <- if (include_self) mv_all_packages() else mv_core_packages()
  states <- vapply(pkgs, pkg_state, character(1))

  rows <- list()
  no_news <- character()
  for (pkg in pkgs[states == "ok"]) {
    raw <- pkg_news(pkg)
    sel <- if (is.null(raw)) NULL else select_news_versions(raw, n)
    if (is.null(sel) || nrow(sel) == 0L) {
      no_news <- c(no_news, pkg)
      next
    }
    rows[[pkg]] <- data.frame(
      package = pkg,
      version = as.character(sel$Version),
      date = as.character(sel$Date),
      category = as.character(sel$Category),
      text = as.character(sel$Text),
      stringsAsFactors = FALSE
    )
  }

  out <- if (length(rows) > 0L) {
    do.call(rbind, unname(rows))
  } else {
    data.frame(
      package = character(), version = character(), date = character(),
      category = character(), text = character(), stringsAsFactors = FALSE
    )
  }
  rownames(out) <- NULL
  attr(out, "not_installed") <- pkgs[states == "absent"]
  attr(out, "broken") <- pkgs[states == "broken"]
  attr(out, "no_news") <- no_news
  attr(out, "n") <- n
  class(out) <- c("mediationverse_news", "data.frame")

  print(out)
  invisible(out)
}

#' @export
print.mediationverse_news <- function(x, ...) {
  cli::cli_h1("mediationverse news")

  df <- as.data.frame(unclass(x), stringsAsFactors = FALSE)
  for (pkg in unique(df$package)) {
    cli::cli_h2("{pkg}")
    sub <- df[df$package == pkg, , drop = FALSE]
    for (ver in unique(sub$version)) {
      vrows <- sub[sub$version == ver, , drop = FALSE]
      date <- vrows$date[1]
      heading <- if (is.na(date) || !nzchar(date)) ver else paste0(ver, " (", date, ")")
      cat(heading, "\n", sep = "")
      for (txt in vrows$text) {
        cat("* ", news_one_line(txt), "\n", sep = "")
      }
    }
  }

  not_installed <- attr(x, "not_installed")
  broken <- attr(x, "broken")
  no_news <- attr(x, "no_news")
  if (length(no_news) > 0) {
    cli::cli_alert_info("No NEWS available for: {.pkg {no_news}}")
  }
  if (length(not_installed) > 0) {
    cli::cli_alert_info("Not installed: {.pkg {not_installed}}")
  }
  if (length(broken) > 0) {
    cli::cli_alert_warning("Installed but cannot be loaded: {.pkg {broken}}")
  }

  invisible(x)
}

# Rows of `df` (columns Version, Date, Category, Text) for the `n` highest
# parseable versions, newest version first, bullet order kept within a version.
#' @noRd
select_news_versions <- function(df, n) {
  parsed <- suppressWarnings(numeric_version(as.character(df$Version), strict = FALSE))
  keep <- !is.na(parsed)
  df <- df[keep, , drop = FALSE]
  parsed <- parsed[keep]
  if (nrow(df) == 0L) {
    return(df)
  }

  uniq <- unique(as.character(df$Version))
  uniq_parsed <- numeric_version(uniq, strict = FALSE)
  top <- uniq[order(uniq_parsed, decreasing = TRUE)][seq_len(min(n, length(uniq)))]

  df <- df[df$Version %in% top, , drop = FALSE]
  df[order(match(as.character(df$Version), top)), , drop = FALSE]
}

# Collapse whitespace to one line and cap the length.
#' @noRd
news_one_line <- function(x, width = 200L) {
  x <- gsub("\\s+", " ", trimws(as.character(x)))
  if (is.na(x)) x <- ""
  if (nchar(x) > width) x <- paste0(substr(x, 1L, width - 3L), "...")
  x
}

# News for one package as a plain data.frame (Version, Date, Category, Text), or
# NULL when it has no usable NEWS. Isolated so tests can mock it.
#' @noRd
pkg_news <- function(pkg) {
  res <- tryCatch(
    suppressWarnings(utils::news(package = pkg)),
    error = function(e) NULL
  )
  if (is.null(res) || NROW(res) == 0L) {
    return(NULL)
  }
  as.data.frame(res)[, c("Version", "Date", "Category", "Text"), drop = FALSE]
}
