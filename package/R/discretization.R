#' Discretize one numerical variable using equal-width intervals.
#'
#' Equal-width discretization transforms a continuous numerical vector into an
#' ordered categorical vector. The function splits the range from the minimum to
#' the maximum observed value into intervals with the same width. Missing values
#' are ignored when calculating the limits and remain missing in the result.
#'
#' @param x Numerical vector to discretize.
#' @param bins Number of intervals to create. Must be a positive integer.
#' @return Ordered factor with labels `bin_1`, `bin_2`, and so on.
#' @export
discretize_equal_width <- function(x, bins = 5) {
  if (!is.numeric(x)) stop("equal-width discretization requires a numeric vector.")
  if (bins < 1 || bins != as.integer(bins)) stop("bins must be a positive integer.")
  result <- rep(NA_character_, length(x))
  valid <- !is.na(x)
  if (!any(valid)) return(factor(result))
  if (min(x[valid]) == max(x[valid])) {
    result[valid] <- "bin_1"
    return(factor(result))
  }
  result[valid] <- as.character(cut(x[valid], breaks = bins, include.lowest = TRUE, labels = paste0("bin_", seq_len(bins))))
  factor(result, levels = paste0("bin_", seq_len(bins)), ordered = TRUE)
}

#' Discretize one numerical variable using equal-frequency bins.
#'
#' Equal-frequency discretization sorts the valid observations and creates bins
#' with approximately the same number of rows. The numerical width of the bins
#' can be different, but the frequency of observations per bin is more balanced.
#'
#' @param x Numerical vector to discretize.
#' @param bins Desired number of bins. If the vector has fewer unique values,
#'   the effective number of bins is reduced.
#' @return Ordered factor with labels `bin_1`, `bin_2`, and so on.
#' @export
discretize_equal_frequency <- function(x, bins = 5) {
  if (!is.numeric(x)) stop("equal-frequency discretization requires a numeric vector.")
  if (bins < 1 || bins != as.integer(bins)) stop("bins must be a positive integer.")
  result <- rep(NA_character_, length(x))
  valid <- !is.na(x)
  if (!any(valid)) return(factor(result))
  if (length(unique(x[valid])) == 1) {
    result[valid] <- "bin_1"
    return(factor(result))
  }
  effective_bins <- min(bins, length(unique(x[valid])))
  ranks <- rank(x[valid], ties.method = "first")
  result[valid] <- as.character(cut(ranks, breaks = effective_bins, include.lowest = TRUE, labels = paste0("bin_", seq_len(effective_bins))))
  factor(result, levels = paste0("bin_", seq_len(effective_bins)), ordered = TRUE)
}

#' Apply equal-width discretization to numeric columns in a data frame.
#'
#' This is the dataset version of `discretize_equal_width`. It returns a copy of
#' the input data frame and replaces only the selected numerical columns with
#' equal-width bin labels.
#'
#' @param data Data frame containing the variables to transform.
#' @param bins Number of equal-width intervals for each selected column.
#' @param columns Optional character vector with column names. If `NULL`, all
#'   numerical columns are transformed.
#' @return Data frame with selected columns transformed into ordered factors.
#' @export
discretize_dataset_equal_width <- function(data, bins = 5, columns = NULL) {
  result <- data
  if (is.null(columns)) columns <- names(result)[vapply(result, is.numeric, logical(1))]
  for (column in columns) result[[column]] <- discretize_equal_width(result[[column]], bins = bins)
  result
}

#' Apply equal-frequency discretization to numeric columns in a data frame.
#'
#' This is the dataset version of `discretize_equal_frequency`. It returns a
#' copy of the input data frame and replaces only the selected numerical columns
#' with approximately equal-frequency bin labels.
#'
#' @param data Data frame containing the variables to transform.
#' @param bins Desired number of frequency groups for each selected column.
#' @param columns Optional character vector with column names. If `NULL`, all
#'   numerical columns are transformed.
#' @return Data frame with selected columns transformed into ordered factors.
#' @export
discretize_dataset_equal_frequency <- function(data, bins = 5, columns = NULL) {
  result <- data
  if (is.null(columns)) columns <- names(result)[vapply(result, is.numeric, logical(1))]
  for (column in columns) result[[column]] <- discretize_equal_frequency(result[[column]], bins = bins)
  result
}
