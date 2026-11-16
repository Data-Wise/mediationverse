# Internal registry of mediationverse ecosystem members.
#
# Single source of truth for the member list, GitHub repositories, install
# sources and minimum versions. Everything that needs to know "which packages
# are in the ecosystem" reads from here instead of hardcoding its own vector.
#
# Columns:
#   package     Package name.
#   repo        GitHub repository ("owner/name"), also used for CRAN members
#               as an install hint.
#   source      Where the recommended install comes from: "CRAN" or "GitHub".
#   core        TRUE for ecosystem members, FALSE for mediationverse itself.
#   min_version Minimum version required by the strictest dependent in the
#               ecosystem (NA when no dependent declares one). Seeded from the
#               sibling DESCRIPTION files on 2026-11-16: missingmed requires
#               medfit (>= 0.3.1) and RMediation (>= 1.5.0).
#
# Row order is the order members are listed to users: mediationverse first,
# then the core members.

#' @noRd
mv_registry <- function() {
  data.frame(
    package = c(
      "mediationverse", "medfit", "probmed", "RMediation",
      "medrobust", "medsim", "missingmed"
    ),
    repo = c(
      "Data-Wise/mediationverse", "Data-Wise/medfit", "Data-Wise/probmed",
      "Data-Wise/rmediation", "Data-Wise/medrobust", "Data-Wise/medsim",
      "Data-Wise/missingmed"
    ),
    source = c(
      "GitHub", "GitHub", "GitHub", "CRAN",
      "GitHub", "GitHub", "GitHub"
    ),
    core = c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE),
    min_version = c(NA, "0.3.1", NA, "1.5.0", NA, NA, NA),
    stringsAsFactors = FALSE
  )
}

# Names of the six core ecosystem members (excludes mediationverse itself).
#' @noRd
mv_core_packages <- function() {
  reg <- mv_registry()
  reg$package[reg$core]
}

# Names of every registered package, mediationverse first.
#' @noRd
mv_all_packages <- function() {
  mv_registry()$package
}

# Named character vector: package -> "Data-Wise/<repo>".
#' @noRd
mv_repos <- function() {
  reg <- mv_registry()
  repos <- reg$repo
  names(repos) <- reg$package
  repos
}

# Names of packages whose recommended install source is CRAN.
#' @noRd
mv_cran_packages <- function() {
  reg <- mv_registry()
  reg$package[reg$source == "CRAN"]
}

# Names of packages whose recommended install source is GitHub.
#' @noRd
mv_github_packages <- function() {
  reg <- mv_registry()
  reg$package[reg$source == "GitHub"]
}

# Recommended install source ("CRAN" or "GitHub") for one package.
#' @noRd
mv_source <- function(package) {
  reg <- mv_registry()
  reg$source[match(package, reg$package)]
}
