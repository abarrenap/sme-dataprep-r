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

#' Discretize one numerical variable using manual thresholds.
#'
#' Manual-threshold discretization is useful when the cut points have a
#' practical interpretation. The thresholds are sorted and used to create
#' intervals from `-Inf` to `Inf`. Missing values remain missing.
#'
#' @param x Numerical vector to discretize.
#' @param thresholds Numerical vector with cut points.
#' @param labels Optional labels. Must contain one more value than
#'   `thresholds`.
#' @return Ordered factor with threshold-based groups.
#' @export
discretize_by_thresholds <- function(x, thresholds, labels = NULL) {
  if (!is.numeric(x)) stop("threshold discretization requires a numeric vector.")
  if (!is.numeric(thresholds)) stop("thresholds must be numeric.")
  thresholds <- sort(thresholds[!is.na(thresholds)])
  if (is.null(labels)) labels <- paste0("bin_", seq_len(length(thresholds) + 1))
  if (length(labels) != length(thresholds) + 1) {
    stop("labels must contain exactly length(thresholds) + 1 values.")
  }
  cut(x, breaks = c(-Inf, thresholds, Inf), labels = labels, include.lowest = TRUE, ordered_result = TRUE)
}

#' Discretize one numerical variable by standard deviations from the mean.
#'
#' The function converts values to z-scores and then discretizes those z-scores
#' using standard-deviation thresholds. The default thresholds `-1` and `1`
#' produce three groups: low, typical, and high.
#'
#' @param x Numerical vector to discretize.
#' @param sd_thresholds Cut points expressed in standard deviations from the
#'   mean.
#' @param labels Optional labels. Defaults to `low`, `typical`, and `high` for
#'   the default thresholds.
#' @return Ordered factor with standard-deviation groups.
#' @export
discretize_by_standard_deviation <- function(x, sd_thresholds = c(-1, 1), labels = NULL) {
  if (!is.numeric(x)) stop("standard-deviation discretization requires a numeric vector.")
  sd_thresholds <- sort(sd_thresholds[!is.na(sd_thresholds)])
  if (is.null(labels) && identical(sd_thresholds, c(-1, 1))) labels <- c("low", "typical", "high")
  if (is.null(labels)) labels <- paste0("bin_", seq_len(length(sd_thresholds) + 1))
  if (length(labels) != length(sd_thresholds) + 1) {
    stop("labels must contain exactly length(sd_thresholds) + 1 values.")
  }
  valid <- !is.na(x)
  result <- rep(NA_character_, length(x))
  if (!any(valid)) return(factor(result, levels = labels, ordered = TRUE))
  mean_x <- mean(x[valid])
  sd_x <- sqrt(mean((x[valid] - mean_x)^2))
  if (sd_x == 0) {
    result[valid] <- labels[min(floor(length(labels) / 2) + 1, length(labels))]
    return(factor(result, levels = labels, ordered = TRUE))
  }
  z_scores <- (x - mean_x) / sd_x
  discretize_by_thresholds(z_scores, thresholds = sd_thresholds, labels = labels)
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

#' Apply manual-threshold discretization to numeric columns in a data frame.
#'
#' @param data Data frame containing the variables to transform.
#' @param thresholds Numerical vector used for every selected column, or a named
#'   list whose entries contain thresholds for each column.
#' @param columns Optional character vector with column names. If `NULL`, all
#'   numerical columns are transformed.
#' @param labels Optional labels shared by all transformed columns.
#' @return Data frame with selected columns transformed into ordered factors.
#' @export
discretize_dataset_by_thresholds <- function(data, thresholds, columns = NULL, labels = NULL) {
  result <- data
  if (is.null(columns)) columns <- names(result)[vapply(result, is.numeric, logical(1))]
  for (column in columns) {
    column_thresholds <- if (is.list(thresholds)) thresholds[[column]] else thresholds
    result[[column]] <- discretize_by_thresholds(result[[column]], thresholds = column_thresholds, labels = labels)
  }
  result
}

#' Apply standard-deviation discretization to numeric columns in a data frame.
#'
#' @param data Data frame containing the variables to transform.
#' @param sd_thresholds Cut points expressed in standard deviations from each
#'   column mean.
#' @param columns Optional character vector with column names. If `NULL`, all
#'   numerical columns are transformed.
#' @param labels Optional labels shared by all transformed columns.
#' @return Data frame with selected columns transformed into ordered factors.
#' @export
discretize_dataset_by_standard_deviation <- function(data, sd_thresholds = c(-1, 1), columns = NULL, labels = NULL) {
  result <- data
  if (is.null(columns)) columns <- names(result)[vapply(result, is.numeric, logical(1))]
  for (column in columns) {
    result[[column]] <- discretize_by_standard_deviation(result[[column]], sd_thresholds = sd_thresholds, labels = labels)
  }
  result
}
