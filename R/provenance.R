# Where an installed package actually came from, read from its own DESCRIPTION.
#
# Fields seen in practice:
#   GitHub (pak / remotes):  RemoteType "github"
#   CRAN:                    Repository "CRAN" (RemoteType "standard")
#   r-universe:              Repository or RemoteRepos naming *.r-universe.dev
#   source / load_all:       none of the above -> "local"
#
# Returns one of "CRAN", "GitHub", "r-universe", "base", "local", "other", or NA when
# the package is not installed or its description cannot be read. Internal and
# mockable, like the other pkg_*() helpers.

#' @noRd
pkg_provenance <- function(pkg) {
  if (!nzchar(system.file(package = pkg))) {
    return(NA_character_)
  }
  desc <- tryCatch(
    suppressWarnings(utils::packageDescription(pkg)),
    error = function(e) NA
  )
  if (!is.list(desc)) {
    return(NA_character_)
  }

  field <- function(name) {
    val <- desc[[name]]
    if (is.null(val) || is.na(val)) "" else as.character(val)
  }
  repo <- c(field("Repository"), field("RemoteRepos"))

  if (identical(field("Priority"), "base")) {
    "base"
  } else if (identical(field("RemoteType"), "github")) {
    "GitHub"
  } else if (any(grepl("r-universe\\.dev", repo))) {
    "r-universe"
  } else if (identical(field("Repository"), "CRAN") ||
               any(grepl("cran", repo, ignore.case = TRUE))) {
    "CRAN"
  } else if (!nzchar(field("RemoteType")) && !nzchar(field("Repository"))) {
    "local"
  } else {
    "other"
  }
}
