# Newest available version of a package on its recommended install source.
#
# Network access is opt-in: only sitrep(updates = TRUE) and
# mediationverse_update(only_outdated = TRUE) call this, never package load.
# Everything here fails soft: offline, a timeout or an unexpected payload gives
# NA, never an error or warning.

# Latest available version of one registry member from its recommended source
# ("CRAN" -> crandb, "GitHub" -> the Data-Wise r-universe), or NA when it cannot
# be determined. Isolated so tests can mock it.
#' @noRd
pkg_latest <- function(pkg, source) {
  if (!is.character(pkg) || length(pkg) != 1L || !pkg %in% mv_all_packages()) {
    return(NA_character_)
  }
  url <- switch(
    as.character(source)[1],
    CRAN = paste0("https://crandb.r-pkg.org/", pkg),
    GitHub = paste0("https://data-wise.r-universe.dev/api/packages/", pkg),
    return(NA_character_)
  )
  parse_remote_version(read_remote(url))
}

# Pull the "Version" field out of a flat JSON payload (crandb and r-universe
# both return one). A regex rather than a JSON parser keeps jsonlite out of the
# dependencies; anything that does not look like a version gives NA.
#' @noRd
parse_remote_version <- function(txt) {
  if (length(txt) != 1L || is.na(txt)) {
    return(NA_character_)
  }
  m <- regmatches(txt, regexec('"Version"\\s*:\\s*"([^"]+)"', txt))[[1]]
  if (length(m) != 2L) {
    return(NA_character_)
  }
  ver <- m[2]
  if (is.na(suppressWarnings(numeric_version(ver, strict = FALSE)))) {
    return(NA_character_)
  }
  ver
}

# Read a URL as one string, with a short timeout; NA on any failure. Isolated
# so tests can mock it.
#' @noRd
read_remote <- function(url) {
  old <- options(timeout = 5)
  on.exit(options(old), add = TRUE)
  tryCatch(
    suppressWarnings({
      con <- url(url, "r")
      on.exit(close(con), add = TRUE)
      paste(readLines(con, warn = FALSE), collapse = " ")
    }),
    error = function(e) NA_character_
  )
}
