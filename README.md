# SME DataPrep R

`sme-dataprep-r` provides educational data-preprocessing utilities for the
Software Matemático y Estadístico coursework. The repository contains the
`smeDataPrep` package, an R Markdown walkthrough, and its rendered PDF.

## Repository layout

```text
.
├── README.md
├── data/
│   ├── diabetes/
│   │   └── diabetes_prediction_dataset.csv
│   └── titanic/
│       ├── test.csv
│       └── train.csv
├── usage_examples.Rmd
├── usage_examples.pdf
└── package/
    ├── DESCRIPTION
    ├── NAMESPACE
    ├── R/
    │   ├── associations.R
    │   ├── dataset.R
    │   ├── discretization.R
    │   ├── management.R
    │   ├── metrics.R
    │   ├── preprocessing.R
    │   └── visualization.R
```

## Install directly from GitHub

The R package can be installed directly from this public repository with
`devtools`:

```r
install.packages("devtools") # Run once if devtools is not installed
devtools::install_github("abarrenap/sme-dataprep-r", subdir = "package")
```

Install `devtools` in a clean R session before rendering the example document.
If R reports that an older `rlang` namespace is already loaded, restart R,
update it with `install.packages("rlang")`, restart R once more, and then install
`devtools`.

The `subdir` argument is required because the package source is stored in the
repository's `package/` directory.

After installation, load it normally:

```r
library(smeDataPrep)
```

The package provides an `sme_dataset` object for CSV data and an optional target,
dataset summaries and type/missing-value checks, imputation, normalization and
standardization, discretization, filtering, association measures, AUC/ROC
utilities, and visualizations.

## Install from a local clone

From this folder, install the local package source with:

```r
install.packages("remotes")
remotes::install_local("package")
```

During development, you can also load the package with:

```r
devtools::load_all("package")
```

## Render the R Markdown example

The example file is `usage_examples.Rmd`; the repository also includes the
current rendered output, `usage_examples.pdf`. The document installs the GitHub
package at render time, loads `smeDataPrep`, and uses the repository's local
`data/` files. Render it from this repository folder:

```r
rmarkdown::render("usage_examples.Rmd")
```

This requires `devtools`, Pandoc, and a LaTeX distribution. RStudio usually
includes Pandoc automatically. If LaTeX is missing, the lightweight option is
TinyTeX:

```r
install.packages("tinytex")
tinytex::install_tinytex()
```

## Example datasets

The R Markdown document uses two datasets:

1. `data/titanic/train.csv` is used for a general preprocessing walkthrough because it has numerical variables, categorical variables, missing values, and a binary target.
2. `data/diabetes/diabetes_prediction_dataset.csv` is used for a compact realistic analysis focused on target validation, missing-value checks, AUC/ROC, distribution plots, and short conclusions.

- Titanic binary target: `Survived`
- Numerical variables: `Age`, `SibSp`, `Parch`, `Fare`
- Categorical variables: `Pclass`, `Sex`, `Embarked`

- Diabetes binary target: `diabetes`
- Main numerical variables: `age`, `bmi`, `HbA1c_level`, `blood_glucose_level`
- Other relevant variables: `hypertension`, `heart_disease`, `gender`, `smoking_history`

The first section treats the Titanic file as a generic supervised table rather than focusing on its story. The final diabetes section is more analytical and interprets the most relevant outputs.

The AUC visualization section includes two different plots:

- `plot_roc_curve`: the standard ROC curve for one numerical attribute.
- `plot_roc_curves`: several ROC curves in one figure, using selected columns or all numerical columns when `columns = NULL`.
- `compare_auc_values`: a barplot that compares final AUC values across several numerical attributes.

Additional implemented extras:

- `discretize_by_thresholds`: manual cut points chosen by the analyst.
- `discretize_by_standard_deviation`: groups values by distance from the mean.
- `plot_variable_distribution`: density plot, optionally split by target class.
- `dataset_summary`: compact overview of rows, columns, and a variable report that includes types and missing-value information.
- `missing_value_report`: missing counts and missing percentages by variable.
- `detect_variable_types`: practical type detection for numerical, categorical, binary, identifier, and high-cardinality variables.
- `validate_binary_target`: checks that a target exists and has exactly two classes.
- `impute_missing_values`: simple missing-value imputation with median/mode or explicit strategies.

## Package source

The installable R package lives in `package/`. Its metadata is in
`package/DESCRIPTION`, and its exported functions are listed in
`package/NAMESPACE`.
