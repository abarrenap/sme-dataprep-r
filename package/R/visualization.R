#' Plot AUC values for numerical attributes.
#'
#' The plot compares the AUC values of all numerical variables against a binary
#' target. Taller bars indicate variables whose larger values are more strongly
#' associated with the positive class.
#'
#' @param data Data frame containing numerical variables and a binary target.
#' @param target Name of the binary target column.
#' @param positive_class Optional value treated as the positive class.
#' @return Invisibly returns the data frame of AUC values used in the plot.
#' @export
plot_auc_values <- function(data, target, positive_class = NULL) {
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
