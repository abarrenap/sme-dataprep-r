#' Calculate Pearson correlation for two numerical vectors.
#'
#' Pearson correlation measures linear association between two numerical
#' variables. Values close to 1 indicate that both variables tend to increase
#' together, values close to -1 indicate an inverse linear relationship, and
#' values close to 0 indicate little linear association.
#'
#' @param x First numerical vector.
#' @param y Second numerical vector with the same length as `x`.
#' @return A single numeric correlation coefficient. Missing pairs are ignored.
#'   If one variable has zero variance, the function returns 0.
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
#' Mutual information measures how much knowing one categorical variable reduces
#' uncertainty about another. It is calculated from entropy using
#' `MI(X, Y) = H(X) + H(Y) - H(X, Y)`, where `H(X, Y)` is the entropy of the
#' joint distribution.
#'
#' @param x First categorical or discrete vector.
#' @param y Second categorical or discrete vector with the same length as `x`.
#' @param base Logarithm base used in the entropy calculation.
#' @return A single numeric mutual information value. Missing pairs are ignored.
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
#' @param data Data frame containing numerical and/or categorical variables.
#' @return Square numeric matrix. Rows and columns are variable names, and each
#'   cell contains the association value for that pair.
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
