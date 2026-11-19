# Perform enrichment tests on relational data

`test_enrich` allows to test enrichment for the target feature of a
multifactor or a linkmap output by
[`weave_coverage()`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md)
based on the origin feature.

## Arguments

- x:

  A linkmap with coverage metadata from
  [`weave_coverage()`](https://minotau-r.github.io/multifactor/reference/weave_coverage-generic.md).

- log_base:

  `Integer`. Base of logarithm for log-fold (default: 2).

## Value

A data.frame with the enrichment statistics, including the following
variables:

- expected: Expected percent coverage

- observed: Observed percent coverage

- fold: Fold effect size

- log_fold: Log fold effect size based on `log_base` argument

- p.value: Uncorrected p-values

- p.adj: FDR-adjusted p-values
