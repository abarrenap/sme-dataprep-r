#' Normalize a numerical vector to the [0, 1] range.
#'
#' Normalization changes the scale of a numerical variable without changing the
#' order of its observations. The minimum valid value becomes 0, the maximum
#' valid value becomes 1, and all other values are placed proportionally between
#' them. Missing values remain missing.
#'
#' @param x Numerical vector to normalize.
#' @return Numerical vector scaled to `[0, 1]`. If all valid values are equal,
#'   valid positions are returned as 0.
#' @export
normalize_variable <- function(x) {
  if (!is.numeric(x)) stop("normalization requires a numeric vector.")
  result <- rep(NA_real_, length(x))
  valid <- !is.na(x)
  if (!any(valid)) return(result)
  minimum <- min(x[valid])
  maximum <- max(x[valid])
  if (minimum == maximum) {
    result[valid] <- 0
  } else {
    result[valid] <- (x[valid] - minimum) / (maximum - minimum)
  }
  result
}

#' Standardize a numerical vector to mean 0 and standard deviation 1.
#'
#' Standardization converts values to z-scores by subtracting the mean and
#' dividing by the standard deviation. This makes numerical variables with
#' different units easier to compare. Missing values remain missing.
#'
#' @param x Numerical vector to standardize.
#' @return Numerical vector of z-scores. If the variable has zero standard
#'   deviation, valid positions are returned as 0.
#' @export
standardize_variable <- function(x) {
  if (!is.numeric(x)) stop("standardization requires a numeric vector.")
  result <- rep(NA_real_, length(x))
  valid <- !is.na(x)
  if (!any(valid)) return(result)
  mean_x <- mean(x[valid])
  sd_x <- sqrt(mean((x[valid] - mean_x)^2))
  result[valid] <- if (sd_x == 0) 0 else (x[valid] - mean_x) / sd_x
  result
}

#' Normalize numeric columns in a data frame.
#'
#' Applies `normalize_variable` to several columns and returns a modified copy of
#' the dataset. Non-selected columns are preserved without changes.
#'
#' @param data Data frame containing the variables to transform.
#' @param columns Optional character vector with column names. If `NULL`, all
#'   numerical columns are transformed.
#' @return Data frame with selected numerical columns scaled to `[0, 1]`.
#' @export
normalize_dataset <- function(data, columns = NULL) {
  result <- data
  if (is.null(columns)) columns <- names(result)[vapply(result, is.numeric, logical(1))]
  for (column in columns) result[[column]] <- normalize_variable(result[[column]])
  result
}

#' Standardize numeric columns in a data frame.
#'
#' Applies `standardize_variable` to several columns and returns a modified copy
#' of the dataset. Non-selected columns are preserved without changes.
#'
#' @param data Data frame containing the variables to transform.
#' @param columns Optional character vector with column names. If `NULL`, all
#'   numerical columns are transformed.
#' @return Data frame with selected numerical columns transformed to z-scores.
#' @export
standardize_dataset <- function(data, columns = NULL) {
  result <- data
  if (is.null(columns)) columns <- names(result)[vapply(result, is.numeric, logical(1))]
  for (column in columns) result[[column]] <- standardize_variable(result[[column]])
  result
}

#' Filter variables according to a metric threshold.
#'
#' The function first calculates attribute metrics, then keeps only variables
#' whose selected metric satisfies the comparison rule. This is a simple feature
#' filtering method for reducing a dataset before later analysis.
#'
#' @param data Data frame containing the candidate variables.
#' @param metric Metric name to filter by, such as `variance`, `auc`, or
#'   `entropy`.
#' @param threshold Numeric threshold used in the comparison.
#' @param operator Comparison operator: `>=`, `>`, `<=`, or `<`.
#' @param target Optional binary target column for AUC.
#' @param positive_class Optional positive class value for AUC.
#' @return Data frame containing the variables that pass the filter. If `target`
#'   is provided, the target column is also kept.
#' @export
filter_variables <- function(data, metric, threshold, operator = ">=", target = NULL, positive_class = NULL) {
  metrics <- attribute_metrics(data, target = target, positive_class = positive_class)
  selected <- metrics[metrics$metric == metric, ]
  keep <- switch(
    operator,
    ">=" = selected$attribute[selected$value >= threshold],
    ">" = selected$attribute[selected$value > threshold],
    "<=" = selected$attribute[selected$value <= threshold],
    "<" = selected$attribute[selected$value < threshold],
    stop("operator must be one of >=, >, <=, <.")
  )
  columns <- unique(as.character(keep))
  if (!is.null(target) && target %in% names(data)) columns <- c(columns, target)
  data[columns]
}
