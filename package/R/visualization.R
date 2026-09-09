#' Plot the ROC curve for one numerical attribute.
#'
#' The ROC curve is the standard visual representation behind AUC. For each
#' possible threshold of the numerical score, the function calculates the true
#' positive rate and false positive rate. The diagonal line represents random
#' ordering, and the legend shows the AUC value calculated by `auc_score`.
#'
#' @param scores Numerical vector with the attribute values to evaluate.
#' @param target Binary target vector with the same length as `scores`.
#' @param positive_class Optional value treated as the positive class.
#' @param label Optional label used in the plot legend.
#' @return Invisibly returns a data frame with thresholds, false positive rates,
#'   and true positive rates.
#' @export
plot_roc_curve <- function(scores, target, positive_class = NULL, label = "attribute") {
  valid <- !is.na(scores) & !is.na(target)
  scores <- scores[valid]
  target <- target[valid]
  classes <- unique(target)
  if (length(classes) != 2) stop("ROC curve requires exactly two target classes.")
  positive <- if (is.null(positive_class)) classes[2] else positive_class
  positive_count <- sum(target == positive)
  negative_count <- sum(target != positive)
  if (positive_count == 0 || negative_count == 0) {
    stop("ROC curve requires at least one positive and one negative example.")
  }

  thresholds <- c(Inf, sort(unique(scores), decreasing = TRUE), -Inf)
  curve <- data.frame(
    threshold = thresholds,
    false_positive_rate = numeric(length(thresholds)),
    true_positive_rate = numeric(length(thresholds))
  )

  for (i in seq_along(thresholds)) {
    predicted_positive <- scores >= thresholds[i]
    true_positive <- sum(target == positive & predicted_positive)
    false_positive <- sum(target != positive & predicted_positive)
    curve$true_positive_rate[i] <- true_positive / positive_count
    curve$false_positive_rate[i] <- false_positive / negative_count
  }

  auc <- auc_score(scores, target, positive_class = positive)
  plot(
    curve$false_positive_rate,
    curve$true_positive_rate,
    type = "l",
    lwd = 2,
    xlim = c(0, 1),
    ylim = c(0, 1),
    xlab = "False positive rate",
    ylab = "True positive rate",
    main = "ROC curve"
  )
  lines(curve$false_positive_rate, curve$true_positive_rate, type = "p", pch = 16, cex = 0.5)
  abline(0, 1, lty = 2, col = "gray")
  legend(
    "bottomright",
    legend = c(paste0(label, " (AUC = ", round(auc, 3), ")"), "random baseline"),
    lty = c(1, 2),
    col = c("black", "gray"),
    bty = "n"
  )
  invisible(curve)
}

#' Compare AUC values for numerical attributes.
#'
#' This summary barplot compares the final AUC values of all numerical variables
#' against a binary target. It is useful for comparing variables, but it is not
#' the ROC curve itself. Use `plot_roc_curve` for the standard ROC visualization
#' of one numerical attribute.
#'
#' @param data Data frame containing numerical variables and a binary target.
#' @param target Name of the binary target column.
#' @param positive_class Optional value treated as the positive class.
#' @return Invisibly returns the data frame of AUC values used in the plot.
#' @export
compare_auc_values <- function(data, target, positive_class = NULL) {
  metrics <- attribute_metrics(data, target = target, positive_class = positive_class)
  auc_values <- metrics[metrics$metric == "auc", ]
  auc_values <- auc_values[order(auc_values$value, decreasing = TRUE), ]
  barplot(
    auc_values$value,
    names.arg = auc_values$attribute,
    ylim = c(0, 1),
    ylab = "AUC",
    xlab = "Attribute",
    main = "AUC by numerical attribute",
    las = 2
  )
  invisible(auc_values)
}

#' Backward-compatible alias for `compare_auc_values`.
#'
#' Prefer `compare_auc_values` in new code because it describes the barplot more
#' accurately.
#'
#' @param data Data frame containing numerical variables and a binary target.
#' @param target Name of the binary target column.
#' @param positive_class Optional value treated as the positive class.
#' @return Invisibly returns the data frame of AUC values used in the plot.
#' @export
plot_auc_values <- function(data, target, positive_class = NULL) {
  compare_auc_values(data, target = target, positive_class = positive_class)
}

#' Plot an association matrix.
#'
#' Displays the output of `association_matrix` as a heatmap. This makes it
#' easier to identify strong pairwise relationships between variables.
#'
#' @param matrix Numeric association matrix returned by `association_matrix`.
#' @return Invisibly returns the input matrix.
#' @export
plot_association_matrix <- function(matrix) {
  image(
    seq_len(ncol(matrix)),
    seq_len(nrow(matrix)),
    t(matrix[nrow(matrix):1, , drop = FALSE]),
    axes = FALSE,
    xlab = "",
    ylab = "",
    main = "Association matrix"
  )
  axis(1, at = seq_len(ncol(matrix)), labels = colnames(matrix), las = 2)
  axis(2, at = seq_len(nrow(matrix)), labels = rev(rownames(matrix)), las = 2)
  invisible(matrix)
}
