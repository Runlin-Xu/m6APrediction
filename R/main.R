# Functions reused from Practical 5. Add documentation in your new package.
#' Encode DNA Sequence Positions as Factors
#'
#' Split equal-length DNA strings into nucleotide-position columns.
#' @param dna_strings Character vector of equal-length DNA strings containing
#'   A, T, C and G. The supplied model uses five-base contexts.
#' @return A data frame with one factor column per nucleotide position,
#'   named nt_pos1, nt_pos2 and so on, with levels A, T, C and G.
dna_encoding <- function(dna_strings){
  nn <- nchar(dna_strings[1])
  seq_m <- matrix(unlist(strsplit(dna_strings, "")), ncol = nn, byrow = TRUE)
  colnames(seq_m) <- paste0("nt_pos", 1:nn)
  seq_df <- as.data.frame(seq_m)
  seq_df[] <- lapply(seq_df, factor, levels = c("A", "T", "C", "G"))
  return(seq_df)
}

#' Predict m6A for Multiple Sites
#'
#' Predict positive-class probabilities and statuses using the supplied model.
#' DNA positions are encoded internally as factors.
#' @param ml_fit Fitted random forest classifier with a Positive class.
#' @param feature_df Data frame containing gc_content, RNA_type, RNA_region,
#'   exon_length, distance_to_junction, evolutionary_conservation and DNA_5mer.
#'   RNA_type uses mRNA, lincRNA, lncRNA or pseudogene. RNA_region uses CDS,
#'   intron, 3'UTR or 5'UTR. Length and distance use the supplied log2 scale.
#'   DNA_5mer contains five-base contexts with A at the central position.
#' @param positive_threshold Numeric probability threshold. A score strictly
#'   greater than this threshold is Positive; equality is Negative.
#' @return The input data frame with factor RNA annotations and added numeric
#'   predicted_m6A_prob and character predicted_m6A_status columns.
#' @import randomForest
#' @importFrom stats predict
#' @export
#' @examples
#' ml_fit <- readRDS(system.file("extdata", "rf_fit.rds",
#'                             package = "m6APrediction", mustWork = TRUE))
#' feature_df <- read.csv(system.file("extdata", "m6A_input_example.csv",
#'                                  package = "m6APrediction", mustWork = TRUE))
#' prediction_multiple(ml_fit, feature_df[1:3, ], positive_threshold = 0.6)
prediction_multiple <- function(ml_fit, feature_df, positive_threshold = 0.5){
  stopifnot(all(c("gc_content", "RNA_type", "RNA_region", "exon_length", "distance_to_junction",
                  "evolutionary_conservation", "DNA_5mer") %in% colnames(feature_df))) # Check errors if incorrect column names of input data.frame
  feature_df$RNA_type <- factor(feature_df$RNA_type, levels = c("mRNA", "lincRNA", "lncRNA", "pseudogene"))
  feature_df$RNA_region <- factor(feature_df$RNA_region, levels = c("CDS", "intron", "3'UTR", "5'UTR"))
  infered_prob <- predict(ml_fit, newdata = cbind(feature_df, dna_encoding(feature_df$DNA_5mer)), type = "prob")
  feature_df$predicted_m6A_prob <- infered_prob[,"Positive"]
  feature_df$predicted_m6A_status <- "Negative"
  feature_df$predicted_m6A_status[feature_df$predicted_m6A_prob > positive_threshold] <- "Positive"
  return(feature_df) # Return a data.frame with predicted m6A prob and predicted m6A status
}

#' Predict m6A for a Single Site
#'
#' Construct one feature row and call prediction_multiple().
#' @param ml_fit Fitted random forest classifier with a Positive class.
#' @param gc_content Numeric GC-content feature on the supplied scale.
#' @param RNA_type Character RNA type: mRNA, lincRNA, lncRNA or pseudogene.
#' @param RNA_region Character RNA region: CDS, intron, 3'UTR or 5'UTR.
#' @param exon_length Numeric exon length on the supplied log2 scale.
#' @param distance_to_junction Numeric distance on the supplied log2 scale.
#' @param evolutionary_conservation Numeric conservation feature.
#' @param DNA_5mer Five-base DNA context with A at the central position.
#' @param positive_threshold Numeric probability threshold. A score strictly
#'   greater than this threshold is Positive; equality is Negative.
#' @return A named character vector with predicted_m6A_prob and
#'   predicted_m6A_status. Combining the probability with text makes both
#'   elements character values.
#' @export
#' @examples
#' ml_fit <- readRDS(system.file("extdata", "rf_fit.rds",
#'                             package = "m6APrediction", mustWork = TRUE))
#' prediction_single(ml_fit, gc_content = 0.6, RNA_type = "mRNA",
#'                   RNA_region = "CDS", exon_length = 12,
#'                   distance_to_junction = 5, evolutionary_conservation = 0.8,
#'                   DNA_5mer = "GGACA", positive_threshold = 0.5)
prediction_single <- function(ml_fit, gc_content, RNA_type, RNA_region, exon_length,
                              distance_to_junction, evolutionary_conservation, DNA_5mer, positive_threshold = 0.5){
  pred_outcome <- prediction_multiple(ml_fit = ml_fit,
                                      data.frame(gc_content = gc_content,
                                                 RNA_type = factor(RNA_type, levels = c("mRNA", "lincRNA", "lncRNA", "pseudogene")),
                                                 RNA_region = factor(RNA_region, levels = c("CDS", "intron", "3'UTR", "5'UTR")),
                                                 exon_length = exon_length,
                                                 distance_to_junction = distance_to_junction,
                                                 evolutionary_conservation = evolutionary_conservation,
                                                 DNA_5mer = DNA_5mer),
                                      positive_threshold = positive_threshold)
  returned_vector <- c(pred_outcome$predicted_m6A_prob, pred_outcome$predicted_m6A_status)
  names(returned_vector) <- c("predicted_m6A_prob", "predicted_m6A_status")
  return(returned_vector) # Return a named vector with predicted m6A prob and predicted m6A status
}
