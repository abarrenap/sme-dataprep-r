#' Create an SME dataset object.
#'
#' `sme_dataset` is a small S3 object that stores a data frame together with an
#' optional target column name. It is useful for keeping the dataset and its
#' supervised target together when applying the preprocessing functions.
#'
#' @param data Data frame to store.
#' @param target Optional name of the target column. The column must exist in
#'   `data` when provided.
#' @return Object of class `sme_dataset` with fields `data` and `target`.
#' @export
sme_dataset <- function(data, target = NULL) {
  if (!is.data.frame(data)) stop("data must be a data frame.")
  if (!is.null(target) && !(target %in% names(data))) stop("target column not found.")
  structure(list(data = data, target = target), class = "sme_dataset")
}

#' Print an SME dataset object.
#'
#' Displays a compact summary with number of rows, number of columns, and the
#' target column if one is defined.
#'
#' @param x SME dataset object.
#' @param ... Additional arguments, currently unused.
#' @export
print.sme_dataset <- function(x, ...) {
  cat("SME dataset\n")
  cat("Rows:", nrow(x$data), "\n")
  cat("Columns:", ncol(x$data), "\n")
  if (!is.null(x$target)) cat("Target:", x$target, "\n")
  invisible(x)
}

#' Read an SME dataset from CSV.
#'
#' This helper reads a CSV file with base R and wraps the resulting data frame
#' in an `sme_dataset` object.
#'
#' @param path Path to the CSV file.
#' @param target Optional target column name.
#' @param ... Additional arguments passed to `read.csv`.
#' @return SME dataset object.
#' @export
read_sme_dataset <- function(path, target = NULL, ...) {
  sme_dataset(read.csv(path, ...), target = target)
}

#' Write an SME dataset to CSV.
#'
#' This helper writes the data frame inside an `sme_dataset` object to a CSV
#' file. Row names are not written.
#'
#' @param dataset SME dataset object to write.
#' @param path Output CSV path.
#' @param ... Additional arguments passed to `write.csv`.
#' @return The output path, invisibly.
#' @export
write_sme_dataset <- function(dataset, path, ...) {
  if (!inherits(dataset, "sme_dataset")) stop("dataset must be an sme_dataset object.")
  write.csv(dataset$data, path, row.names = FALSE, ...)
  invisible(path)
}
