# Package startup and attachment

.onAttach <- function(libname, pkgname) {
  # Get version information
  med_version <- utils::packageVersion("mediationverse")

  # Try to attach medfit (foundation package only)
  tryCatch(
    mediationverse_attach(),
    error = function(e) {
      packageStartupMessage(
        "medfit could not be loaded.\n",
        "Please ensure it is installed:\n",
        "  pak::pak('Data-Wise/medfit')"
      )
      return(invisible())
    }
  )

  # Get medfit version
  medfit_version <- tryCatch(
    as.character(utils::packageVersion("medfit")),
    error = function(e) "(not installed)"
  )

  # Create startup message using cli if available
  if (requireNamespace("cli", quietly = TRUE)) {
    tick <- cli::symbol$tick
    info <- cli::symbol$info
    msg <- paste0(
      cli::rule(
        left = "Attaching mediationverse",
        right = med_version
      ),
      "\n",
      tick, " medfit ", medfit_version, " (foundation package)\n",
      info, " Use library(probmed) for P_med effect size\n",
      info, " Use library(RMediation) for DOP/MBCO inference\n",
      info, " Use library(medrobust) for sensitivity analysis\n",
      info, " Use library(medsim) for simulation utilities\n",
      cli::rule()
    )
  } else {
    # Fallback message if cli is not available
    msg <- paste0(
      "-- Attaching mediationverse ", med_version, " --\n",
      "+ medfit ", medfit_version, " (foundation package)\n",
      "i Use library(probmed) for P_med effect size\n",
      "i Use library(RMediation) for DOP/MBCO inference\n",
      "i Use library(medrobust) for sensitivity analysis\n",
      "i Use library(medsim) for simulation utilities\n",
      "-------------------------------------------------------------"
    )
  }

  packageStartupMessage(msg)
}
