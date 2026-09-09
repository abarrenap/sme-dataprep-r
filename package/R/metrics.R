#' Calculate variance for a numerical vector.
#'
#' Variance measures how spread out the values of a numerical variable are
#' around their mean. A value close to zero means the observations are very
#' similar, while a larger value means the variable changes more across the
#' dataset. Missing values are removed before the calculation.
#'
#' @param x Numerical vector with the values to evaluate.
#' @param sample Logical. If `FALSE`, divide by `n` and calculate population
#'   variance. If `TRUE`, divide by `n - 1` when possible and calculate sample
#'   variance.
#' @return A single numeric value with the variance. Returns `NaN` when there
#'   are no non-missing values.
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
#' Entropy measures uncertainty or diversity in a categorical variable. If all
#' observations belong to the same category, entropy is zero. If categories are
#' more evenly distributed, entropy is higher. The implementation calculates the
#' relative frequency of each category and applies `-sum(p * log(p))`.
#'
#' @param x Vector with categorical or already discretized values.
#' @param base Logarithm base. The default value `2` expresses entropy in bits.
#' @return A single numeric entropy value. Missing values are ignored.
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
#' AUC means Area Under the ROC Curve. It evaluates whether a numerical
#' attribute orders the two classes of a binary target correctly. This function
#' implements AUC using pairwise comparisons: each positive observation is
#' compared with each negative observation. A comparison counts as 1 when the
#' positive observation has a higher score, 0.5 when both scores are tied, and 0
#' otherwise. The final AUC is the average over all positive-negative pairs.
#'
#' @param scores Numerical vector with the attribute values to evaluate.
#' @param target Binary class vector with the same length as `scores`.
#' @param positive_class Value considered positive. If `NULL`, the second class
#'   found in `target` is used.
#' @return A single numeric AUC value between 0 and 1.
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
#' This function inspects each column and chooses the metric required by the
#' assignment. Numerical variables receive variance. If a binary target is
#' provided, numerical variables also receive AUC. Non-numerical variables
#' receive entropy. The target column is skipped as an explanatory attribute.
#'
#' @param data Data frame containing the variables to evaluate.
#' @param target Optional name of the binary target column used for AUC.
#' @param positive_class Optional positive class value used for AUC.
#' @return A data frame with three columns: `attribute`, `metric`, and `value`.
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
