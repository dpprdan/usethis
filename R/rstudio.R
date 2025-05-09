#' Add RStudio Project infrastructure
#'
#' It is likely that you want to use [create_project()] or [create_package()]
#' instead of `use_rstudio()`! Both `create_*()` functions can add RStudio
#' Project infrastructure to a pre-existing project or package. `use_rstudio()`
#' is mostly for internal use or for those creating a usethis-like package for
#' their organization. It does the following in the current project, often after
#' executing `proj_set(..., force = TRUE)`:
#'   * Creates an `.Rproj` file
#'   * Adds RStudio files to `.gitignore`
#'   * Adds RStudio files to `.Rbuildignore`, if project is a package
#'
#' @param line_ending Line ending
#' @param reformat If `TRUE`, the `.Rproj` is setup with common options that
#'   reformat files on save: adding a trailing newline, trimming trailing
#'   whitespace, and setting the line-ending. This is best practice for
#'   new projects.
#'
#'   If `FALSE`, these options are left unset, which is more appropriate when
#'   you're contributing to someone else's project that does not have its own
#'   `.Rproj` file.
#' @export
use_rstudio <- function(line_ending = c("posix", "windows"), reformat = TRUE) {
  line_ending <- arg_match(line_ending)
  line_ending <- c("posix" = "Posix", "windows" = "Windows")[[line_ending]]

  rproj_file <- paste0(project_name(), ".Rproj")
  new <- use_template(
    "template.Rproj",
    save_as = rproj_file,
    data = list(
      line_ending = line_ending,
      is_pkg = is_package(),
      reformat = reformat
    ),
    ignore = is_package()
  )

  use_git_ignore(".Rproj.user")
  if (is_package()) {
    use_build_ignore(".Rproj.user")
  }

  invisible(new)
}

#' Don't save/load user workspace between sessions
#'
#' R can save and reload the user's workspace between sessions via an `.RData`
#' file in the current directory. However, long-term reproducibility is enhanced
#' when you turn this feature off and clear R's memory at every restart.
#' Starting with a blank slate provides timely feedback that encourages the
#' development of scripts that are complete and self-contained. More detail can
#' be found in the blog post [Project-oriented
#' workflow](https://www.tidyverse.org/blog/2017/12/workflow-vs-script/).
#'
#' @inheritParams edit
#'
#' @export
use_blank_slate <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)

  if (scope == "user") {
    use_rstudio_preferences(
      save_workspace = "never",
      load_workspace = FALSE
    )
  } else {
    rproj_fields <- modify_rproj(
      rproj_path(),
      list(RestoreWorkspace = "No", SaveWorkspace = "No")
    )
    write_utf8(rproj_path(), serialize_rproj(rproj_fields))
    restart_rstudio("Restart RStudio with a blank slate?")
  }

  invisible()
}

# Is base_path an RStudio Project or inside an RStudio Project?
is_rstudio_project <- function(base_path = proj_get()) {
  length(rproj_paths(base_path)) == 1
}

rproj_paths <- function(base_path, recurse = FALSE) {
  dir_ls(base_path, regexp = "[.]Rproj$", recurse = recurse)
}

# Return path to single .Rproj or die trying
rproj_path <- function(base_path = proj_get(), call = caller_env()) {
  rproj <- rproj_paths(base_path)
  if (length(rproj) == 1) {
    rproj
  } else if (length(rproj) == 0) {
    name <- project_name(base_path)
    cli::cli_abort("{.val {name}} is not an RStudio Project.", call = call)
  } else {
    name <- project_name(base_path)
    cli::cli_abort(
      c(
        "{.val {name}} must contain a single .Rproj file.",
        i = "Found {.file {path_rel(rproj, base_path)}}."
      ),
      call = call
    )
  }
}

# Is base_path open in RStudio?
in_rstudio <- function(base_path = proj_get()) {
  if (!rstudio_available()) {
    return(FALSE)
  }

  if (!rstudioapi::hasFun("getActiveProject")) {
    return(FALSE)
  }

  proj <- rstudioapi::getActiveProject()

  if (is.null(proj)) {
    return(FALSE)
  }

  path_real(proj) == path_real(base_path)
}

# So we can override the default with a mock
rstudio_available <- function() {
  rstudioapi::isAvailable()
}

in_rstudio_server <- function() {
  if (!rstudio_available()) {
    return(FALSE)
  }
  identical(rstudioapi::versionInfo()$mode, "server")
}

parse_rproj <- function(file) {
  lines <- as.list(read_utf8(file))
  has_colon <- grepl(":", lines)
  fields <- lapply(lines[has_colon], function(x) strsplit(x, split = ": ")[[1]])
  lines[has_colon] <- vapply(fields, `[[`, "character", 2)
  names(lines)[has_colon] <- vapply(fields, `[[`, "character", 1)
  names(lines)[!has_colon] <- ""
  lines
}

modify_rproj <- function(file, update) {
  utils::modifyList(parse_rproj(file), update)
}

serialize_rproj <- function(fields) {
  named <- nzchar(names(fields))
  as.character(ifelse(named, paste0(names(fields), ": ", fields), fields))
}

# Must be last command run
restart_rstudio <- function(message = NULL) {
  if (!in_rstudio(proj_get())) {
    return(FALSE)
  }

  if (!is_interactive()) {
    return(FALSE)
  }

  if (!is.null(message)) {
    ui_bullets(message)
  }

  if (!rstudioapi::hasFun("openProject")) {
    return(FALSE)
  }

  if (ui_nah("Restart now?")) {
    return(FALSE)
  }

  rstudioapi::openProject(proj_get())
}

rstudio_git_tickle <- function() {
  if (uses_git() && rstudioapi::hasFun("executeCommand")) {
    rstudioapi::executeCommand("vcsRefresh")
  }
  invisible()
}

rstudio_config_path <- function(...) {
  if (is_windows()) {
    # https://github.com/r-lib/usethis/issues/1293
    base <- rappdirs::user_config_dir("RStudio", appauthor = NULL)
  } else {
    # RStudio only uses windows/unix conventions, not mac
    base <- rappdirs::user_config_dir("rstudio", os = "unix")
  }
  path(base, ...)
}

#' Set global RStudio preferences
#'
#' This function allows you to set global RStudio preferences, achieving the
#' same effect programmatically as clicking buttons in RStudio's Global Options.
#' You can find a list of configurable properties at
#' <https://docs.posit.co/ide/server-pro/reference/session_user_settings.html>.
#'
#' @export
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Property-value pairs.
#' @return A named list of the previous values, invisibly.
use_rstudio_preferences <- function(...) {
  new <- dots_list(..., .homonyms = "last")
  if (length(new) > 0 && !is_named(new)) {
    cli::cli_abort("All arguments in {.arg ...} must be named.")
  }

  json <- rstudio_prefs_read()
  old <- json[names(new)]

  for (name in names(new)) {
    val <- new[[name]]

    if (identical(json[[name]], val)) {
      next
    }

    ui_bullets(c(
      "v" = "Setting RStudio preference {.field {name}} to {.val {val}}."
    ))
    json[[name]] <- val
  }

  rstudio_prefs_write(json)
  invisible(old)
}

rstudio_prefs_read <- function() {
  path <- rstudio_config_path("rstudio-prefs.json")
  if (file_exists(path)) {
    jsonlite::read_json(path)
  } else {
    list()
  }
}

rstudio_prefs_write <- function(json) {
  path <- rstudio_config_path("rstudio-prefs.json")
  create_directory(path_dir(path))
  jsonlite::write_json(json, path, auto_unbox = TRUE, pretty = TRUE)
}
