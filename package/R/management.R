#' Detect practical variable types in a data frame.
#'
#' This helper classifies variables as binary, numerical, categorical, possible
#' identifiers, or high-cardinality categorical variables. It is useful before
#' deciding which preprocessing or metric function should be applied.
#'
#' @param data Data frame to inspect.
#' @param high_cardinality_threshold Unique-value proportion above which a
#'   categorical variable is marked as high-cardinality.
#' @return Data frame with variable names, raw classes, detected types, missing
#'   values, and unique-value counts.
#' @export
detect_variable_types <- function(data, high_cardinality_threshold = 0.5) {
  row_count <- nrow(data)
  rows <- vector("list", length(names(data)))
  for (i in seq_along(names(data))) {
    column <- names(data)[i]
    values <- data[[column]]
    non_missing <- values[!is.na(values)]
    unique_count <- length(unique(non_missing))
    unique_rate <- if (length(non_missing) == 0) 0 else unique_count / length(non_missing)
    missing_count <- sum(is.na(values))
    missing_rate <- if (row_count == 0) 0 else missing_count / row_count

    detected_type <- if (unique_count == 2) {
      "binary"
    } else if (is.numeric(values)) {
      if (unique_count == length(non_missing) && row_count > 0) "identifier" else "numerical"
    } else if (unique_rate >= high_cardinality_threshold) {
      "high_cardinality_categorical"
    } else {
      "categorical"
    }

    rows[[i]] <- data.frame(
      variable = column,
      r_class = paste(class(values), collapse = "/"),
      detected_type = detected_type,
      missing_count = missing_count,
      missing_rate = missing_rate,
      unique_count = unique_count,
      unique_rate = unique_rate,
      stringsAsFactors = FALSE
    )
  }
  do.call(rbind, rows)
}

#' Report missing values by variable.
#'
#' @param data Data frame to inspect.
#' @return Data frame ordered by decreasing missing rate with columns
#'   `variable`, `missing_count`, and `missing_rate`.
#' @export
missing_value_report <- function(data) {
  row_count <- nrow(data)
  report <- data.frame(
    variable = names(data),
    missing_count = vapply(data, function(values) sum(is.na(values)), numeric(1)),
    stringsAsFactors = FALSE
  )
  report$missing_rate <- if (row_count == 0) 0 else report$missing_count / row_count
  report[order(report$missing_rate, report$missing_count, decreasing = TRUE), ]
}

#' Create a compact dataset summary.
#'
#' The summary combines dimensions, variable type detection, missing-value
#' information, numerical columns, and categorical columns.
#'
#' @param data Data frame to summarize.
#' @return List with dataset dimensions and summary tables.
#' @export
dataset_summary <- function(data) {
  list(
    n_rows = nrow(data),
    n_columns = ncol(data),
    variables = detect_variable_types(data),
    missing_values = missing_value_report(data),
    numerical_columns = names(data)[vapply(data, is.numeric, logical(1))],
    categorical_columns = names(data)[!vapply(data, is.numeric, logical(1))]
  )
}

#' Validate that a target column exists and has exactly two classes.
#'
#' AUC requires a supervised binary target. This function checks that the target
#' is present and that the non-missing target values contain exactly two
#' distinct classes.
#'
#' @param data Data frame containing the target.
#' @param target Name of the target column.
#' @return `TRUE` when the target is valid.
#' @export
validate_binary_target <- function(data, target) {
  if (!(target %in% names(data))) stop(paste0("target column '", target, "' was not found."))
  classes <- unique(data[[target]][!is.na(data[[target]])])
  if (length(classes) != 2) stop("target must contain exactly two non-missing classes.")
  TRUE
}

#' Impute missing values in selected columns.
#'
#' The function implements simple transparent imputation rules. Numerical
#' columns can be imputed with the mean, median, or a constant. Categorical
#' columns can be imputed with the mode or a constant. With `strategy = "auto"`,
#' numerical columns use the median and categorical columns use the mode.
#'
#' @param data Data frame to impute.
#' @param strategy Imputation strategy: `auto`, `mean`, `median`, `mode`, or
#'   `constant`.
#' @param fill_value Constant value used when `strategy = "constant"`.
#' @param columns Optional character vector with columns to impute. If `NULL`,
#'   all columns are checked.
#' @return Data frame with imputed missing values.
#' @export
impute_missing_values <- function(data, strategy = "auto", fill_value = NULL, columns = NULL) {
  allowed <- c("auto", "mean", "median", "mode", "constant")
  if (!(strategy %in% allowed)) stop(paste("strategy must be one of", paste(allowed, collapse = ", ")))
  if (strategy == "constant" && is.null(fill_value)) {
    stop("fill_value must be provided when strategy = 'constant'.")
  }
  result <- data
  if (is.null(columns)) columns <- names(result)
  for (column in columns) {
    values <- result[[column]]
    if (!any(is.na(values))) next
    column_strategy <- strategy
    if (strategy == "auto") column_strategy <- if (is.numeric(values)) "median" else "mode"

    replacement <- switch(
      column_strategy,
      mean = {
        if (!is.numeric(values)) stop("mean imputation can only be applied to numeric columns.")
        mean(values, na.rm = TRUE)
      },
      median = {
        if (!is.numeric(values)) stop("median imputation can only be applied to numeric columns.")
        median(values, na.rm = TRUE)
      },
      mode = {
        non_missing <- values[!is.na(values)]
        if (length(non_missing) == 0) fill_value else names(sort(table(non_missing), decreasing = TRUE))[1]
      },
      constant = fill_value
    )
    result[[column]][is.na(result[[column]])] <- replacement
  }
  result
}
