#' Create an SME dataset object.
#'
#' @param data Data frame.
#' @param target Optional target column.
#' @return Object of class `sme_dataset`.
#' @export
sme_dataset <- function(data, target = NULL) {
  if (!is.data.frame(data)) stop("data must be a data frame.")
  if (!is.null(target) && !(target %in% names(data))) stop("target column not found.")
  structure(list(data = data, target = target), class = "sme_dataset")
}

#' Print an SME dataset object.
#'
#' @param x SME dataset object.
#' @param ... Additional arguments.
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
#' @param path CSV path.
#' @param target Optional target column.
#' @param ... Additional arguments passed to read.csv.
#' @return SME dataset object.
#' @export
read_sme_dataset <- function(path, target = NULL, ...) {
  sme_dataset(read.csv(path, ...), target = target)
}

#' Write an SME dataset to CSV.
#'
#' @param dataset SME dataset object.
#' @param path Output path.
#' @param ... Additional arguments passed to write.csv.
#' @return Invisible path.
#' @export
write_sme_dataset <- function(dataset, path, ...) {
  if (!inherits(dataset, "sme_dataset")) stop("dataset must be an sme_dataset object.")
  write.csv(dataset$data, path, row.names = FALSE, ...)
  invisible(path)
}
