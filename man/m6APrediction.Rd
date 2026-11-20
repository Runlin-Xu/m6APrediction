\name{m6APrediction}
\alias{m6APrediction}
\title{m6APrediction: Predict m6A Status Using a Random Forest Model}
\description{
m6APrediction predicts m6A probabilities and statuses using the fitted
random forest model supplied in BIO215 Practical 6.

prediction_multiple() predicts sites in a feature table. prediction_single()
predicts one site from gc_content, RNA_type, RNA_region, exon_length,
distance_to_junction, evolutionary_conservation and DNA_5mer.

The package includes rf_fit.rds and m6A_input_example.csv under extdata.
Use the feature scales in the example data and a five-base DNA context
with A at the central position. A probability strictly greater than
positive_threshold is Positive; equality is Negative.

For argument details, use ?prediction_multiple and ?prediction_single.
These teaching examples do not establish prediction accuracy on new
species or independent biological data.
}
\examples{
ml_fit <- readRDS(system.file("extdata", "rf_fit.rds",
                            package = "m6APrediction", mustWork = TRUE))
feature_df <- read.csv(system.file("extdata", "m6A_input_example.csv",
                                 package = "m6APrediction", mustWork = TRUE))
prediction_multiple(ml_fit, feature_df[1:3, ], positive_threshold = 0.6)
prediction_single(ml_fit, gc_content = 0.6, RNA_type = "mRNA",
                  RNA_region = "CDS", exon_length = 12,
                  distance_to_junction = 5, evolutionary_conservation = 0.8,
                  DNA_5mer = "GGACA", positive_threshold = 0.5)
}
