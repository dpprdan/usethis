#' Use a directory
#'
#' `use_directory()` creates a directory (if it does not already exist) in the
#' project's top-level directory. This function powers many of the other `use_`
#' functions such as [use_data()] and [use_vignette()].
#'
#' @param path Path of the directory to create, relative to the project.
#' @inheritParams use_template
#'
#' @export
#' @examples
#' \dontrun{
#' use_directory("inst")
#' }
use_directory <- function(path, ignore = FALSE) {
  create_directory(proj_path(path))
  if (ignore) {
    use_build_ignore(path)
  }

  invisible(TRUE)
}

create_directory <- function(path) {
  if (dir_exists(path)) {
    return(invisible(FALSE))
  } else if (file_exists(path)) {
    ui_abort("{.path {pth(path)}} exists but is not a directory.")
  }

  dir_create(path, recurse = TRUE)
  ui_bullets(c("v" = "Creating {.path {pth(path)}}."))
  invisible(TRUE)
}

check_path_is_directory <- function(path) {
  if (!file_exists(path)) {
    ui_abort("Directory {.path {pth(path)}} does not exist.")
  }

  if (!is_dir(path)) {
    ui_abort("{.path {pth(path)}} is not a directory.")
  }
}

count_directory_files <- function(x) {
  length(dir_ls(x))
}

directory_has_files <- function(x) {
  count_directory_files(x) >= 1
}

check_directory_is_empty <- function(x) {
  if (directory_has_files(x)) {
    ui_abort("{.path {pth(x)}} exists and is not an empty directory.")
  }
  invisible(x)
}
