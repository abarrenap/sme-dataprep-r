#' Calculate Pearson correlation for two numerical vectors.
#'
#' @param x Numerical vector.
#' @param y Numerical vector.
#' @return Correlation value.
#' @export
correlation_pair <- function(x, y) {
  valid <- !is.na(x) & !is.na(y)
  x <- x[valid]
  y <- y[valid]
  if (length(x) == 0) return(NaN)
  x_mean <- mean(x)
  y_mean <- mean(y)
  numerator <- sum((x - x_mean) * (y - y_mean))
  denominator <- sqrt(sum((x - x_mean)^2) * sum((y - y_mean)^2))
  if (denominator == 0) 0 else numerator / denominator
}

#' Calculate mutual information for two categorical vectors.
#'
#' @param x First categorical vector.
#' @param y Second categorical vector.
#' @param base Logarithm base.
#' @return Mutual information value.
#' @export
mutual_information <- function(x, y, base = 2) {
  valid <- !is.na(x) & !is.na(y)
  x <- x[valid]
  y <- y[valid]
  if (length(x) == 0) return(0)
  joint <- paste(x, y, sep = "\r")
  entropy(x, base = base) + entropy(y, base = base) - entropy(joint, base = base)
}

#' Calculate pairwise association matrix for a data frame.
#'
#' Numerical pairs use Pearson correlation. Categorical pairs use mutual
#' information. Mixed numerical-categorical pairs are returned as NA.
#'
#' @param data Data frame.
#' @return Numeric matrix.
#' @export
association_matrix <- function(data) {
  columns <- names(data)
  result <- matrix(NA_real_, nrow = length(columns), ncol = length(columns), dimnames = list(columns, columns))
  for (left in columns) {
    for (right in columns) {
      left_numeric <- is.numeric(data[[left]])
      right_numeric <- is.numeric(data[[right]])
      if (left_numeric && right_numeric) {
        result[left, right] <- correlation_pair(data[[left]], data[[right]])
      } else if (!left_numeric && !right_numeric) {
        result[left, right] <- mutual_information(data[[left]], data[[right]])
      }
    }
  }
  result
}
