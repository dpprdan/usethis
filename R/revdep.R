#' Reverse dependency checks
#'
#' Performs set up for checking the reverse dependencies of an R package, as
#' implemented by the revdepcheck package:
#' * Creates `revdep/` directory and adds it to `.Rbuildignore`
#' * Populates `revdep/.gitignore` to prevent tracking of various revdep
#' artefacts
#' * Prompts user to run the checks with `revdepcheck::revdep_check()`
#'
#' @export
use_revdep <- function() {
  check_is_package("use_revdep()")
  use_directory("revdep", ignore = TRUE)
  use_git_ignore(
    directory = "revdep",
    c(
      "checks",
      "library",
      "checks.noindex",
      "library.noindex",
      "cloud.noindex",
      "data.sqlite",
      "*.html"
    )
  )

  ui_bullets(c(
    "_" = "Run checks with {.run revdepcheck::revdep_check(num_workers = 4)}."
  ))
  invisible()
}
