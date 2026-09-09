# SME DataPrep R

`sme-dataprep-r` contains the R implementation for the Software Matemático y Estadístico assignment. The repository includes a standalone R Markdown usage document and a separate installable R package.

## Repository layout

```text
.
├── README.md
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

## Dataset recommendation

For the final `.Rmd`, use a tabular dataset with:

- Numerical variables for variance, AUC, normalization, standardization, correlation, and discretization.
- Categorical variables for entropy and mutual information.
- One binary target/class variable, because AUC needs a supervised binary class.
- Clear column names and a moderate number of rows, so the examples remain readable.

Customer churn, credit default, Titanic survival, heart disease, bank marketing, or loan approval datasets are good candidates.

## Publishing later

R packages are commonly made public through GitHub, where users can install them with `devtools::install_github("username/repository")`. Publishing to CRAN is also possible, but it requires stricter checks, documentation, examples, and package policy compliance.
