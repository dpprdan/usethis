#' Legacy functions related to user interface
#'
#' @description
#' `r lifecycle::badge("superseded")`
#'

#'   These functions are now superseded. External users of the `usethis::ui_*()`
#'   functions are encouraged to use the [cli package](https://cli.r-lib.org/)
#'   instead. The cli package did not have the required functionality when the
#'   `usethis::ui_*()` functions were created, but it has had that for a while
#'   now and it's the superior option. There is even a cli vignette about how to
#'   make this transition: `vignette("usethis-ui", package = "cli")`.
#'
#'   usethis itself now uses cli internally for its UI, but these new functions
#'   are not exported and presumably never will be. There is a developer-focused
#'   article on the process of transitioning usethis's own UI to use cli:
#'   [Converting usethis's UI to use cli](https://usethis.r-lib.org/articles/ui-cli-conversion.html).

#' @details
#'
#' The `ui_` functions can be broken down into four main categories:
#'
#' * block styles: `ui_line()`, `ui_done()`, `ui_todo()`, `ui_oops()`,
#'   `ui_info()`.
#' * conditions: `ui_stop()`, `ui_warn()`.
#' * questions: [ui_yeah()], [ui_nope()].
#' * inline styles: `ui_field()`, `ui_value()`, `ui_path()`, `ui_code()`,
#'   `ui_unset()`.
#'
#' The question functions [ui_yeah()] and [ui_nope()] have their own [help
#' page][ui-questions].
#'
#' All UI output (apart from `ui_yeah()`/`ui_nope()` prompts) can be silenced
#' by setting `options(usethis.quiet = TRUE)`. Use [ui_silence()] to silence
#' selected actions.
#'
#' @param x A character vector.
#'
#'   For block styles, conditions, and questions, each element of the
#'   vector becomes a line, and the result is processed by [glue::glue()].
#'   For inline styles, each element of the vector becomes an entry in a
#'   comma separated list.
#' @param .envir Used to ensure that [glue::glue()] gets the correct
#'   environment. For expert use only.
#'
#' @return The block styles, conditions, and questions are called for their
#'   side-effect. The inline styles return a string.
#' @keywords internal
#' @name ui-legacy-functions
#' @examples
#' new_val <- "oxnard"
#' ui_done("{ui_field('name')} set to {ui_value(new_val)}")
#' ui_todo("Redocument with {ui_code('devtools::document()')}")
#'
#' ui_code_block(c(
#'   "Line 1",
#'   "Line 2",
#'   "Line 3"
#' ))
NULL

# Block styles ------------------------------------------------------------

#' @rdname ui-legacy-functions
#' @export
ui_line <- function(x = character(), .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  ui_inform(x)
}

#' @rdname ui-legacy-functions
#' @export
ui_todo <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  ui_legacy_bullet(x, crayon::red(cli::symbol$bullet))
}

#' @rdname ui-legacy-functions
#' @export
ui_done <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  ui_legacy_bullet(x, crayon::green(cli::symbol$tick))
}

#' @rdname ui-legacy-functions
#' @export
ui_oops <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  ui_legacy_bullet(x, crayon::red(cli::symbol$cross))
}

#' @rdname ui-legacy-functions
#' @export
ui_info <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  ui_legacy_bullet(x, crayon::yellow(cli::symbol$info))
}

#' @param copy If `TRUE`, the session is interactive, and the clipr package
#'   is installed, will copy the code block to the clipboard.
#' @rdname ui-legacy-functions
#' @export
ui_code_block <- function(
  x,
  copy = rlang::is_interactive(),
  .envir = parent.frame()
) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)

  block <- indent(x, "  ")
  block <- crayon::silver(block)
  ui_inform(block)

  if (copy && clipr::clipr_available()) {
    x <- crayon::strip_style(x)
    clipr::write_clip(x)
    ui_inform("  [Copied to clipboard]")
  }
}

# Conditions --------------------------------------------------------------

#' @rdname ui-legacy-functions
#' @export
ui_stop <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)

  cnd <- structure(
    class = c("usethis_error", "error", "condition"),
    list(message = x)
  )

  stop(cnd)
}

#' @rdname ui-legacy-functions
#' @export
ui_warn <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)

  warning(x, call. = FALSE, immediate. = TRUE)
}


# Questions ---------------------------------------------------------------
#' User interface - Questions
#'
#' @description
#' `r lifecycle::badge("superseded")`
#'

#' `ui_yeah()` and `ui_nope()` are technically superseded, but, unlike the rest
#' of the legacy [`ui_*()`][ui-legacy-functions] functions, there's not yet a
#' drop-in replacement available in the [cli package](https://cli.r-lib.org/).
#' `ui_yeah()` and `ui_nope()` are no longer used internally in usethis.
#'
#' @inheritParams ui-legacy-functions
#' @param yes A character vector of "yes" strings, which are randomly sampled to
#'   populate the menu.
#' @param no A character vector of "no" strings, which are randomly sampled to
#'   populate the menu.
#' @param n_yes An integer. The number of "yes" strings to include.
#' @param n_no An integer. The number of "no" strings to include.
#' @param shuffle A logical. Should the order of the menu options be randomly
#'   shuffled?
#'
#' @return A logical. `ui_yeah()` returns `TRUE` when the user selects a "yes"
#'   option and `FALSE` otherwise, i.e. when user selects a "no" option or
#'   refuses to make a selection (cancels). `ui_nope()` is the logical opposite
#'   of `ui_yeah()`.
#' @name ui-questions
#' @keywords internal
#' @examples
#' \dontrun{
#' ui_yeah("Do you like R?")
#' ui_nope("Have you tried turning it off and on again?", n_yes = 1, n_no = 1)
#' ui_yeah("Are you sure its plugged in?", yes = "Yes", no = "No", shuffle = FALSE)
#' }
NULL

#' @rdname ui-questions
#' @export
ui_yeah <- function(
  x,
  yes = c(
    "Yes",
    "Definitely",
    "For sure",
    "Yup",
    "Yeah",
    "I agree",
    "Absolutely"
  ),
  no = c("No way", "Not now", "Negative", "No", "Nope", "Absolutely not"),
  n_yes = 1,
  n_no = 2,
  shuffle = TRUE,
  .envir = parent.frame()
) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)

  if (!is_interactive()) {
    ui_stop(c(
      "User input required, but session is not interactive.",
      "Query: {x}"
    ))
  }

  n_yes <- min(n_yes, length(yes))
  n_no <- min(n_no, length(no))

  qs <- c(sample(yes, n_yes), sample(no, n_no))

  if (shuffle) {
    qs <- sample(qs)
  }

  # TODO: should this be ui_inform()?
  # later observation: probably not? you would not want these prompts to be
  # suppressed when `usethis.quiet = TRUE`, i.e. if the menu() appears, then
  # the introduction should also always appear
  rlang::inform(x)
  out <- utils::menu(qs)
  out != 0L && qs[[out]] %in% yes
}

#' @rdname ui-questions
#' @export
ui_nope <- function(
  x,
  yes = c(
    "Yes",
    "Definitely",
    "For sure",
    "Yup",
    "Yeah",
    "I agree",
    "Absolutely"
  ),
  no = c("No way", "Not now", "Negative", "No", "Nope", "Absolutely not"),
  n_yes = 1,
  n_no = 2,
  shuffle = TRUE,
  .envir = parent.frame()
) {
  # TODO(jennybc): is this correct in the case of no selection / cancelling?
  !ui_yeah(
    x = x,
    yes = yes,
    no = no,
    n_yes = n_yes,
    n_no = n_no,
    shuffle = shuffle,
    .envir = .envir
  )
}

# Inline styles -----------------------------------------------------------

#' @rdname ui-legacy-functions
#' @export
ui_field <- function(x) {
  x <- crayon::green(x)
  x <- glue_collapse(x, sep = ", ")
  x
}

#' @rdname ui-legacy-functions
#' @export
ui_value <- function(x) {
  if (is.character(x)) {
    x <- encodeString(x, quote = "'")
  }
  x <- crayon::blue(x)
  x <- glue_collapse(x, sep = ", ")
  x
}

#' @rdname ui-legacy-functions
#' @export
#' @param base If specified, paths will be displayed relative to this path.
ui_path <- function(x, base = NULL) {
  ui_value(ui_path_impl(x, base = base))
}

#' @rdname ui-legacy-functions
#' @export
ui_code <- function(x) {
  x <- encodeString(x, quote = "`")
  x <- crayon::silver(x)
  x <- glue_collapse(x, sep = ", ")
  x
}

#' @rdname ui-legacy-functions
#' @export
ui_unset <- function(x = "unset") {
  check_string(x)
  x <- glue("<{x}>")
  x <- crayon::silver(x)
  x
}

# rlang::inform() wrappers -----------------------------------------------------

indent <- function(x, first = "  ", indent = first) {
  x <- gsub("\n", paste0("\n", indent), x)
  paste0(first, x)
}

ui_legacy_bullet <- function(x, bullet = cli::symbol$bullet) {
  bullet <- paste0(bullet, " ")
  x <- indent(x, bullet, "  ")
  ui_inform(x)
}

# All UI output must eventually go through ui_inform() so that it
# can be quieted with 'usethis.quiet' when needed.
ui_inform <- function(...) {
  if (!is_quiet()) {
    inform(paste0(...))
  }
  invisible()
}
