\name{core-functions}
\alias{association_matrix}
\alias{attribute_metrics}
\alias{auc_score}
\alias{correlation_pair}
\alias{discretize_dataset_equal_frequency}
\alias{discretize_dataset_equal_width}
\alias{discretize_equal_frequency}
\alias{discretize_equal_width}
\alias{entropy}
\alias{filter_variables}
\alias{mutual_information}
\alias{normalize_dataset}
\alias{normalize_variable}
\alias{plot_association_matrix}
\alias{plot_auc_values}
\alias{read_sme_dataset}
\alias{sme_dataset}
\alias{standardize_dataset}
\alias{standardize_variable}
\alias{variance_metric}
\alias{write_sme_dataset}
\title{Core data preprocessing functions}
\description{
Functions for discretization, metrics, normalization, standardization,
variable filtering, pairwise association, plotting, and a small S3 dataset
object used in the SME coursework package.
}
\usage{
discretize_equal_width(x, bins = 5)
discretize_equal_frequency(x, bins = 5)
discretize_dataset_equal_width(data, bins = 5, columns = NULL)
discretize_dataset_equal_frequency(data, bins = 5, columns = NULL)
variance_metric(x, sample = FALSE)
entropy(x, base = 2)
auc_score(scores, target, positive_class = NULL)
attribute_metrics(data, target = NULL, positive_class = NULL)
normalize_variable(x)
standardize_variable(x)
normalize_dataset(data, columns = NULL)
standardize_dataset(data, columns = NULL)
filter_variables(data, metric, threshold, operator = ">=", target = NULL, positive_class = NULL)
correlation_pair(x, y)
mutual_information(x, y, base = 2)
association_matrix(data)
sme_dataset(data, target = NULL)
read_sme_dataset(path, target = NULL, ...)
write_sme_dataset(dataset, path, ...)
plot_auc_values(data, target, positive_class = NULL)
plot_association_matrix(matrix)
}
\arguments{
\item{x}{A vector.}
\item{y}{A second vector.}
\item{bins}{Number of bins or intervals.}
\item{data}{A data frame.}
\item{columns}{Optional columns to transform.}
\item{sample}{Use sample variance when \code{TRUE}.}
\item{base}{Logarithm base for entropy or mutual information.}
\item{scores}{Numerical scores for AUC.}
\item{target}{Binary target vector or target column name.}
\item{positive_class}{Class value treated as positive.}
\item{metric}{Metric name used for filtering.}
\item{threshold}{Numeric threshold used for filtering.}
\item{operator}{Comparison operator: \code{>=}, \code{>}, \code{<=}, or \code{<}.}
\item{path}{CSV path.}
\item{dataset}{An \code{sme_dataset} object.}
\item{matrix}{Numeric association matrix.}
\item{...}{Additional arguments passed to CSV helpers.}
}
\value{
A vector, data frame, matrix, plot side effect, or \code{sme_dataset} object,
depending on the function called.
}
\examples{
data <- data.frame(
  x = c(1, 2, 3, 4),
  z = c("a", "a", "b", "b"),
  target = c(0, 0, 1, 1)
)
variance_metric(data$x)
entropy(data$z)
auc_score(data$x, data$target, positive_class = 1)
attribute_metrics(data, target = "target", positive_class = 1)
}
