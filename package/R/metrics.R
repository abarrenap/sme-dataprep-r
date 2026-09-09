#' Calculate variance for a numerical vector.
#'
#' @param x Numerical vector.
#' @param sample Logical. Use sample variance when TRUE.
#' @return Numeric variance value.
#' @export
variance_metric <- function(x, sample = FALSE) {
  if (!is.numeric(x)) stop("variance requires a numeric vector.")
  x <- x[!is.na(x)]
  n <- length(x)
  if (n == 0) return(NaN)
  denominator <- if (sample && n > 1) n - 1 else n
  mean_x <- sum(x) / n
  sum((x - mean_x)^2) / denominator
}

#' Calculate Shannon entropy for a discrete vector.
#'
#' @param x Vector with discrete values.
#' @param base Logarithm base.
#' @return Entropy value.
#' @export
entropy <- function(x, base = 2) {
  x <- x[!is.na(x)]
  if (length(x) == 0) return(0)
  counts <- table(x)
  probabilities <- counts / sum(counts)
  -sum(probabilities * (log(probabilities) / log(base)))
}

#' Calculate AUC for numerical scores and a binary target.
#'
#' @param scores Numerical vector with attribute values.
#' @param target Binary class vector.
#' @param positive_class Value considered positive. Defaults to the second class.
#' @return AUC value.
#' @export
auc_score <- function(scores, target, positive_class = NULL) {
  valid <- !is.na(scores) & !is.na(target)
  scores <- scores[valid]
  target <- target[valid]
  classes <- unique(target)
  if (length(classes) != 2) stop("AUC requires exactly two target classes.")
  positive <- if (is.null(positive_class)) classes[2] else positive_class
  positive_scores <- scores[target == positive]
  negative_scores <- scores[target != positive]
  if (length(positive_scores) == 0 || length(negative_scores) == 0) {
    stop("AUC requires at least one positive and one negative example.")
  }
  wins <- 0
  for (score in positive_scores) {
    wins <- wins + sum(score > negative_scores)
    wins <- wins + 0.5 * sum(score == negative_scores)
  }
  wins / (length(positive_scores) * length(negative_scores))
}

#' Calculate suitable metrics for all attributes in a data frame.
#'
#' @param data Data frame.
#' @param target Optional binary target column for AUC.
#' @param positive_class Optional positive class value for AUC.
#' @return Data frame with attribute, metric, and value columns.
#' @export
attribute_metrics <- function(data, target = NULL, positive_class = NULL) {
  rows <- list()
  index <- 1
  for (column in names(data)) {
    if (!is.null(target) && column == target) next
    if (is.numeric(data[[column]])) {
      rows[[index]] <- data.frame(attribute = column, metric = "variance", value = variance_metric(data[[column]]))
      index <- index + 1
      if (!is.null(target)) {
        rows[[index]] <- data.frame(attribute = column, metric = "auc", value = auc_score(data[[column]], data[[target]], positive_class))
        index <- index + 1
      }
    } else {
      rows[[index]] <- data.frame(attribute = column, metric = "entropy", value = entropy(data[[column]]))
      index <- index + 1
    }
  }
  do.call(rbind, rows)
}
