# SME DataPrep R

`sme-dataprep-r` contains the R implementation for the Software Matemático y Estadístico assignment. The repository includes a standalone R Markdown usage document and a separate installable R package.

## Repository layout

```text
.
├── README.md
├── data/
│   └── titanic/
│       ├── test.csv
│       └── train.csv
├── usage_examples.Rmd
└── package/
    ├── DESCRIPTION
    ├── NAMESPACE
    ├── R/
    │   ├── associations.R
    │   ├── dataset.R
    │   ├── discretization.R
    │   ├── metrics.R
    │   ├── preprocessing.R
    │   └── visualization.R
```

## Install locally

From this folder:

```r
install.packages("remotes")
remotes::install_local("package")
```

During development, you can also load the package with:

```r
devtools::load_all("package")
```

## Render the R Markdown example

The example file is `usage_examples.Rmd`. Its main output format is PDF and the author is set to `Aimar Barrena`.

```r
rmarkdown::render("usage_examples.Rmd")
```

This requires Pandoc and a LaTeX distribution to be available on the system path. RStudio usually includes Pandoc automatically. If LaTeX is missing, the lightweight option is TinyTeX:

```r
install.packages("tinytex")
tinytex::install_tinytex()
```

## Current example dataset

The first example uses the Titanic dataset in `data/titanic/train.csv`.

- Binary target: `Survived`
- Numerical variables: `Age`, `SibSp`, `Parch`, `Fare`
- Categorical variables: `Pclass`, `Sex`, `Embarked`

The R Markdown document intentionally ignores identifiers and high-cardinality text fields such as `PassengerId`, `Name`, `Ticket`, and `Cabin` because they make the first explanation less clear.

The AUC visualization section includes two different plots:

- `plot_roc_curve`: the standard ROC curve for one numerical attribute.
- `plot_roc_curves`: several ROC curves in one figure, using selected columns or all numerical columns when `columns = NULL`.
- `compare_auc_values`: a barplot that compares final AUC values across several numerical attributes.

Additional implemented extras:

- `discretize_by_thresholds`: manual cut points chosen by the analyst.
- `discretize_by_standard_deviation`: groups values by distance from the mean.
- `plot_variable_distribution`: density plot, optionally split by target class.
- `dataset_summary`: compact overview of rows, columns, types, and missing values.
- `missing_value_report`: missing counts and missing percentages by variable.
- `detect_variable_types`: practical type detection for numerical, categorical, binary, identifier, and high-cardinality variables.
- `validate_binary_target`: checks that a target exists and has exactly two classes.
- `impute_missing_values`: simple missing-value imputation with median/mode or explicit strategies.

## Second dataset recommendation

For the later second example, choose another tabular dataset with numerical columns, categorical columns, and one binary target. Customer churn, credit default, heart disease, bank marketing, or loan approval datasets are good candidates.

## Publishing later

R packages are commonly made public through GitHub, where users can install them with `devtools::install_github("username/repository")`. Publishing to CRAN is also possible, but it requires stricter checks, documentation, examples, and package policy compliance.
