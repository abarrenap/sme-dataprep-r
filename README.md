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

The example file is `usage_examples.Rmd`. It can be rendered to HTML with:

```r
rmarkdown::render("usage_examples.Rmd")
```

This requires Pandoc to be available on the system path. RStudio usually includes Pandoc automatically.

## Current example dataset

The first example uses the Titanic dataset in `data/titanic/train.csv`.

- Binary target: `Survived`
- Numerical variables: `Age`, `SibSp`, `Parch`, `Fare`
- Categorical variables: `Pclass`, `Sex`, `Embarked`

The R Markdown document intentionally ignores identifiers and high-cardinality text fields such as `PassengerId`, `Name`, `Ticket`, and `Cabin` because they make the first explanation less clear.

## Second dataset recommendation

For the later second example, choose another tabular dataset with numerical columns, categorical columns, and one binary target. Customer churn, credit default, heart disease, bank marketing, or loan approval datasets are good candidates.

## Publishing later

R packages are commonly made public through GitHub, where users can install them with `devtools::install_github("username/repository")`. Publishing to CRAN is also possible, but it requires stricter checks, documentation, examples, and package policy compliance.
