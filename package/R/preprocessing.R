#' Normalize a numerical vector to the [0, 1] range.
#'
#' @param x Numerical vector.
#' @return Normalized numerical vector.
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
#' @param x Numerical vector.
#' @return Standardized numerical vector.
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
#' @param data Data frame.
#' @param columns Optional columns to transform.
#' @return Data frame with normalized numeric columns.
#' @export
normalize_dataset <- function(data, columns = NULL) {
  result <- data
  if (is.null(columns)) columns <- names(result)[vapply(result, is.numeric, logical(1))]
  for (column in columns) result[[column]] <- normalize_variable(result[[column]])
  result
}

#' Standardize numeric columns in a data frame.
#'
#' @param data Data frame.
#' @param columns Optional columns to transform.
#' @return Data frame with standardized numeric columns.
#' @export
standardize_dataset <- function(data, columns = NULL) {
  result <- data
  if (is.null(columns)) columns <- names(result)[vapply(result, is.numeric, logical(1))]
  for (column in columns) result[[column]] <- standardize_variable(result[[column]])
  result
}

#' Filter variables according to a metric threshold.
#'
#' @param data Data frame.
#' @param metric Metric name: variance, auc, or entropy.
#' @param threshold Numeric threshold.
#' @param operator Comparison operator: >=, >, <=, or <.
#' @param target Optional binary target column for AUC.
#' @param positive_class Optional positive class value for AUC.
#' @return Filtered data frame.
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
