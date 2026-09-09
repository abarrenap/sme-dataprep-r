\name{core-functions}
\alias{association_matrix}
\alias{attribute_metrics}
\alias{auc_score}
\alias{correlation_pair}
\alias{discretize_by_standard_deviation}
\alias{discretize_by_thresholds}
\alias{discretize_dataset_by_standard_deviation}
\alias{discretize_dataset_by_thresholds}
\alias{discretize_dataset_equal_frequency}
\alias{discretize_dataset_equal_width}
\alias{discretize_equal_frequency}
\alias{discretize_equal_width}
\alias{entropy}
\alias{filter_variables}
\alias{mutual_information}
\alias{normalize_dataset}
\alias{normalize_variable}
\alias{compare_auc_values}
\alias{plot_association_matrix}
\alias{plot_auc_values}
\alias{plot_roc_curve}
\alias{plot_roc_curves}
\alias{plot_variable_distribution}
\alias{plot_variavle_distribution}
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
\details{
The package is intentionally educational: the required metrics are implemented
directly instead of calling specialized packages that already solve the
assignment.

\strong{Discretization.} \code{discretize_equal_width()} splits the numerical
range of a variable into intervals with the same width. \code{discretize_equal_frequency()}
sorts the observations and creates bins with approximately the same number of
rows. \code{discretize_by_thresholds()} uses analyst-defined cut points.
\code{discretize_by_standard_deviation()} groups values according to their
distance from the mean in standard deviations.

\strong{Variance.} \code{variance_metric()} measures how spread out numerical
values are around their mean. Population variance divides by \code{n}; sample
variance divides by \code{n - 1}.

\strong{Entropy.} \code{entropy()} measures uncertainty in a discrete variable.
It calculates category probabilities and applies \code{-sum(p * log(p))}.

\strong{AUC.} \code{auc_score()} evaluates a numerical attribute against a
binary target. The function compares every positive observation with every
negative observation. Higher positive scores count as one win, ties count as
half a win, and the final AUC is the average across all pairs.
\code{plot_roc_curve()} draws the standard ROC curve for one numerical
attribute by calculating true positive rate and false positive rate at all
possible thresholds. \code{compare_auc_values()} draws a barplot that compares
the final AUC values of several numerical attributes. \code{plot_roc_curves()}
draws several ROC curves in the same plot.

\strong{Normalization and standardization.} \code{normalize_variable()} rescales
values to \code{[0, 1]}. \code{standardize_variable()} converts values to
z-scores by subtracting the mean and dividing by the standard deviation.

\strong{Association matrix.} Numerical pairs use Pearson correlation.
Categorical pairs use mutual information. Mixed numerical-categorical pairs are
returned as \code{NA} in this first version.

\strong{Distribution plots.} \code{plot_variable_distribution()} draws a kernel
density estimate for one numerical variable. If a target is provided and
\code{by_class = TRUE}, it draws one line per class.
}
\usage{
discretize_equal_width(x, bins = 5)
discretize_equal_frequency(x, bins = 5)
discretize_by_thresholds(x, thresholds, labels = NULL)
discretize_by_standard_deviation(x, sd_thresholds = c(-1, 1), labels = NULL)
discretize_dataset_equal_width(data, bins = 5, columns = NULL)
discretize_dataset_equal_frequency(data, bins = 5, columns = NULL)
discretize_dataset_by_thresholds(data, thresholds, columns = NULL, labels = NULL)
discretize_dataset_by_standard_deviation(data, sd_thresholds = c(-1, 1), columns = NULL, labels = NULL)
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
plot_roc_curve(scores, target, positive_class = NULL, label = "attribute")
plot_roc_curves(data, target, columns = NULL, positive_class = NULL)
compare_auc_values(data, target, positive_class = NULL)
plot_auc_values(data, target, positive_class = NULL)
plot_variable_distribution(data, variable, target = NULL, by_class = FALSE)
plot_variavle_distribution(...)
plot_association_matrix(matrix)
}
\arguments{
\item{x}{A vector. It must be numerical for variance, normalization,
standardization, correlation, and discretization. It can be categorical for
entropy and mutual information.}
\item{y}{A second vector with the same length as \code{x}.}
\item{bins}{Number of bins or intervals. Must be a positive integer.}
\item{thresholds}{Numerical cut points used for manual-threshold
discretization. For dataset functions this can also be a named list.}
\item{sd_thresholds}{Cut points expressed in standard deviations from the mean.}
\item{labels}{Optional group labels for discretization functions.}
\item{data}{A data frame containing the variables to transform or evaluate.}
\item{columns}{Optional character vector with column names to transform. If
\code{NULL}, all numerical columns are used where appropriate.}
\item{sample}{Use sample variance when \code{TRUE}; otherwise population
variance is calculated.}
\item{base}{Logarithm base for entropy or mutual information.}
\item{scores}{Numerical scores for AUC. These are usually the values of one
numerical attribute.}
\item{target}{Binary target vector or target column name, depending on the
function.}
\item{positive_class}{Class value treated as positive when calculating AUC.}
\item{label}{Optional label used in the ROC plot legend.}
\item{variable}{Name of the numerical variable to plot.}
\item{by_class}{Logical value. If \code{TRUE}, draw one distribution line per
target class.}
\item{metric}{Metric name used for filtering, such as \code{"variance"},
\code{"auc"}, or \code{"entropy"}.}
\item{threshold}{Numeric threshold used for filtering variables.}
\item{operator}{Comparison operator: \code{>=}, \code{>}, \code{<=}, or \code{<}.}
\item{path}{CSV path for reading or writing a dataset.}
\item{dataset}{An \code{sme_dataset} object.}
\item{matrix}{Numeric association matrix returned by \code{association_matrix}.}
\item{...}{Additional arguments passed to an alias or CSV helpers.}
}
\value{
\code{discretize_*} functions return ordered factors or data frames with
ordered factor columns. Metric functions return numeric values or a data frame
with columns \code{attribute}, \code{metric}, and \code{value}. Preprocessing
functions return transformed vectors or data frames. \code{association_matrix()}
returns a square numeric matrix. \code{plot_roc_curve()} draws a ROC curve and
invisibly returns the curve points. \code{compare_auc_values()} and
\code{plot_auc_values()} draw a comparison barplot and invisibly return the AUC
table used in the plot. \code{plot_variable_distribution()} draws a density
plot and invisibly returns the density object, or a named list of density
objects when grouped by class.
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
