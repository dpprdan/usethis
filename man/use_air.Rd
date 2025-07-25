% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/air.R
\name{use_air}
\alias{use_air}
\title{Configure a project to use Air}
\usage{
use_air(vscode = TRUE)
}
\arguments{
\item{vscode}{Either:
\itemize{
\item \code{TRUE} to set up VS Code and Positron specific Air settings. This is the
default.
\item \code{FALSE} to opt out of those settings.
}}
}
\description{
\href{https://posit-dev.github.io/air}{Air} is an extremely fast R code
formatter. This function sets up a project to use Air. Specifically, it:
\itemize{
\item Creates an empty \code{air.toml} configuration file. If either an \code{air.toml} or
\code{.air.toml} file already existed, nothing is changed. If the project is an
R package, \code{.Rbuildignore} is updated to ignore this file.
\item Creates a \verb{.vscode/} directory and adds recommended settings to
\code{.vscode/settings.json} and \code{.vscode/extensions.json}. These settings are
used by the Air extension installed through either VS Code or Positron, see
the Installation section for more details. Specifically it:
\itemize{
\item Sets \code{editor.formatOnSave = true} for R and Quarto files to enable
formatting on every save.
\item Sets \code{editor.defaultFormatter} to Air for R files to ensure that Air is
always selected as the formatter for this project. Likewise, sets the
default formatter for Quarto.
\item Sets the Air extension as a "recommended" extension for this project,
which triggers a notification for contributors coming to this project
that don't yet have the Air extension installed.
}

If the project is an R package, \code{.Rbuildignore} is updated to ignore the
\verb{.vscode/} directory.

If you'd like to opt out of VS Code / Positron specific setup, set \code{vscode = FALSE}, but remember that even if you work in RStudio, other contributors
may prefer another editor.
}

Note that \code{use_air()} does not actually invoke Air, it just configures your
project with the recommended settings. Consult \href{https://posit-dev.github.io/air/editors.html}{Air's editors guide} to learn how to invoke
Air in your preferred editor.
\subsection{Installation}{

Note that this setup does not install an Air binary, so there may be an
additional manual step you must take before using Air for the first time:
\itemize{
\item For RStudio, follow the \href{https://posit-dev.github.io/air/editor-rstudio.html}{installation guide}.
\item For Positron, the \href{https://open-vsx.org/extension/posit/air-vscode}{Air extension}
is installed by default and that already includes the Air binary. A typical
Positron user does not need to do anything to install Air.
\item For VS Code, install the \href{https://marketplace.visualstudio.com/items?itemName=Posit.air-vscode}{VS Code Extension}.
\item For other editors, check to \href{https://posit-dev.github.io/air/editors.html}{see if that editor is supported} by Air.
}
}
}
\examples{
\dontrun{
# Prepare an R package or project to use Air
use_air()
}
}
