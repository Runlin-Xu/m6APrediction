# m6APrediction

m6APrediction predicts m6A probabilities and statuses for one site or a table of sites using the random forest model supplied in BIO215 Practical 6.

## Installation

Requires R >= 3.5.0. The package imports randomForest and stats.

Install from GitHub:

```r
remotes::install_github("Runlin-Xu/m6APrediction")
```

Alternatively, download `m6APrediction_1.0.0.tar.gz`, set your working directory to its folder, and run:

```r
install.packages("m6APrediction_1.0.0.tar.gz", repos = NULL, type = "source")
```

## Multiple-site prediction

```r
library(m6APrediction)
ml_fit <- readRDS(system.file("extdata", "rf_fit.rds",
                            package = "m6APrediction", mustWork = TRUE))
feature_df <- read.csv(system.file("extdata", "m6A_input_example.csv",
                                 package = "m6APrediction", mustWork = TRUE))
prediction_multiple(ml_fit, feature_df[1:3, ], positive_threshold = 0.6)
```

The returned table adds `predicted_m6A_prob` and `predicted_m6A_status`. The example scores for its first three rows are 0.876, 0.000 and 0.498, with statuses Positive, Negative and Negative.

## Single-site prediction

```r
library(m6APrediction)
ml_fit <- readRDS(system.file("extdata", "rf_fit.rds",
                            package = "m6APrediction", mustWork = TRUE))
prediction_single(ml_fit, gc_content = 0.6, RNA_type = "mRNA",
                  RNA_region = "CDS", exon_length = 12,
                  distance_to_junction = 5, evolutionary_conservation = 0.8,
                  DNA_5mer = "GGACA", positive_threshold = 0.5)
```

This returns a named character vector: `predicted_m6A_prob` is "0.51" and `predicted_m6A_status` is "Positive" for this example.

## Inputs and interpretation

The seven input features are `gc_content`, `RNA_type`, `RNA_region`, `exon_length`, `distance_to_junction`, `evolutionary_conservation` and `DNA_5mer`. Use the feature scales shown in the supplied example data; exon length and junction distance are already log2-transformed. DNA contexts have five bases with A at the centre.

A score strictly greater than `positive_threshold` is Positive; equality is Negative. These examples demonstrate software use with teaching data. They do not establish performance on new species or independent biological data.

## Performance of the bundled Practical 6 model (OOB)

The installed package model was evaluated in the school RStudio Console using its saved out-of-bag (OOB) positive-class votes and matching labels. Each site's OOB score uses trees that did not train on that site. The original model was not retrained.

| Metric | OOB value |
| --- | ---: |
| AUROC | 0.8872636 |
| AUPRC | 0.7022256 |

The evaluation contains 48,055 sites: 11,248 Positive and 36,807 Negative (23.4% Positive). AUROC indicates good discrimination between positive and negative sites. AUPRC is above the positive-class proportion, indicating useful precision-recall performance on these imbalanced teaching data. These are internal OOB estimates, not independent biological validation. A decision threshold still requires considering precision, recall and the costs of false positives and false negatives.

Reproduce the Console calculation (requires precrec):

```r
library(precrec)
m6a_installed_model <- readRDS(system.file("extdata", "rf_fit.rds",
                                         package = "m6APrediction", mustWork = TRUE))
m6a_oob_curves <- evalmod(scores = m6a_installed_model$votes[, "Positive"],
                          labels = m6a_installed_model$y)
auc(m6a_oob_curves)
table(m6a_installed_model$y)
```

## Earlier teaching-model curves (Practical 7 illustration)

![ROC curve from the Practical 3 teaching classifier](inst/figures/ROC.png)

![PRC curve from the Practical 3 teaching classifier](inst/figures/PRC.png)

These figures reproduce Practical3_Assignment Task 2 using its imbalanced teaching data, an 80% training / 20% test split, seed 123 and thresholds from 0.05 to 0.95. The ROC plot shows recall against false-positive rate; the PRC plot shows precision against recall. They illustrate the earlier teaching classifier and are not an independent validation of the model bundled in Practical 6.

## License

MIT license. See `LICENSE` for the year and copyright holder.
