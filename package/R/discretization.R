#' Discretize one numerical variable using equal-width intervals.
#'
#' @param x Numerical vector.
#' @param bins Number of intervals.
#' @return Ordered factor with interval labels.
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
#' @param x Numerical vector.
#' @param bins Number of bins.
#' @return Ordered factor with bin labels.
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
#' @param data Data frame.
#' @param bins Number of intervals.
#' @param columns Optional columns to transform.
#' @return Data frame with transformed columns.
#' @export
discretize_dataset_equal_width <- function(data, bins = 5, columns = NULL) {
  result <- data
  if (is.null(columns)) columns <- names(result)[vapply(result, is.numeric, logical(1))]
  for (column in columns) result[[column]] <- discretize_equal_width(result[[column]], bins = bins)
  result
}

#' Apply equal-frequency discretization to numeric columns in a data frame.
#'
#' @param data Data frame.
#' @param bins Number of bins.
#' @param columns Optional columns to transform.
#' @return Data frame with transformed columns.
#' @export
discretize_dataset_equal_frequency <- function(data, bins = 5, columns = NULL) {
  result <- data
  if (is.null(columns)) columns <- names(result)[vapply(result, is.numeric, logical(1))]
  for (column in columns) result[[column]] <- discretize_equal_frequency(result[[column]], bins = bins)
  result
}
