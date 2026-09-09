roc_curve_points <- function(scores, target, positive_class = NULL) {
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
  curve
}

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
  curve <- roc_curve_points(scores, target, positive_class = positive_class)
  auc <- auc_score(scores, target, positive_class = positive_class)
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

#' Plot ROC curves for several numerical attributes.
#'
#' This function compares several numerical variables against the same binary
#' target. If `columns` is `NULL`, all numerical columns except the target are
#' plotted. Each line includes its AUC value in the legend.
#'
#' @param data Data frame containing numerical attributes and a binary target.
#' @param target Name of the binary target column.
#' @param columns Optional character vector with numerical columns to plot.
#' @param positive_class Optional value treated as the positive class.
#' @return Invisibly returns a named list of ROC curve data frames.
#' @export
plot_roc_curves <- function(data, target, columns = NULL, positive_class = NULL) {
  if (is.null(columns)) {
    columns <- names(data)[vapply(data, is.numeric, logical(1))]
    columns <- columns[columns != target]
  }
  curves <- list()
  plot(
    0,
    0,
    type = "n",
    xlim = c(0, 1),
    ylim = c(0, 1),
    xlab = "False positive rate",
    ylab = "True positive rate",
    main = "ROC curves"
  )
  palette <- seq_along(columns)
  legend_labels <- character(length(columns) + 1)
  for (i in seq_along(columns)) {
    column <- columns[i]
    curve <- roc_curve_points(data[[column]], data[[target]], positive_class = positive_class)
    curves[[column]] <- curve
    lines(curve$false_positive_rate, curve$true_positive_rate, lwd = 2, col = palette[i])
    auc <- auc_score(data[[column]], data[[target]], positive_class = positive_class)
    legend_labels[i] <- paste0(column, " (AUC = ", round(auc, 3), ")")
  }
  abline(0, 1, lty = 2, col = "gray")
  legend_labels[length(legend_labels)] <- "random baseline"
  legend("bottomright", legend = legend_labels, lty = c(rep(1, length(columns)), 2), col = c(palette, "gray"), bty = "n")
  invisible(curves)
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

#' Plot the distribution of a numerical variable.
#'
#' The function draws a kernel density estimate of one numerical variable. When
#' `by_class` is `TRUE`, it draws one density line for each class in the target
#' variable.
#'
#' @param data Data frame containing the variable to plot.
#' @param variable Name of the numerical variable.
#' @param target Optional class column. Required when `by_class` is `TRUE`.
#' @param by_class Logical. If `TRUE`, draw one line per target class.
#' @return Invisibly returns the density object or a named list of density
#'   objects.
#' @export
plot_variable_distribution <- function(data, variable, target = NULL, by_class = FALSE) {
  if (!is.numeric(data[[variable]])) stop("distribution plot requires a numeric variable.")
  if (by_class && is.null(target)) stop("target must be provided when by_class is TRUE.")
  if (by_class) {
    classes <- unique(data[[target]][!is.na(data[[target]])])
    densities <- list()
    plot(
      0,
      0,
      type = "n",
      xlim = range(data[[variable]], na.rm = TRUE),
      ylim = c(0, max(vapply(classes, function(class_value) {
        values <- data[[variable]][data[[target]] == class_value]
        if (sum(!is.na(values)) < 2) return(0)
        max(density(values, na.rm = TRUE)$y)
      }, numeric(1)))),
      xlab = variable,
      ylab = "Density",
      main = paste("Distribution of", variable)
    )
    for (i in seq_along(classes)) {
      class_value <- classes[i]
      values <- data[[variable]][data[[target]] == class_value]
      if (sum(!is.na(values)) < 2) next
      densities[[as.character(class_value)]] <- density(values, na.rm = TRUE)
      lines(densities[[as.character(class_value)]], col = i, lwd = 2)
    }
    legend("topright", legend = paste(target, "=", classes), col = seq_along(classes), lty = 1, bty = "n")
    return(invisible(densities))
  }
  values <- data[[variable]]
  if (sum(!is.na(values)) < 2) stop("distribution plot requires at least two non-missing values.")
  distribution <- density(values, na.rm = TRUE)
  plot(distribution, main = paste("Distribution of", variable), xlab = variable, ylab = "Density", lwd = 2)
  invisible(distribution)
}

#' Alias for `plot_variable_distribution`.
#'
#' Keeps calls with the misspelled function name working.
#'
#' @param ... Arguments passed to `plot_variable_distribution`.
#' @return Same output as `plot_variable_distribution`.
#' @export
plot_variavle_distribution <- function(...) {
  plot_variable_distribution(...)
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
