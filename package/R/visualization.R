#' Plot AUC values for numerical attributes.
#'
#' @param data Data frame.
#' @param target Binary target column.
#' @param positive_class Optional positive class.
#' @return Invisibly returns the AUC data frame.
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
#' @param matrix Numeric association matrix.
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
