#' @title Performs guided discovery of differentially reactive regions.
#'
#' @description This function takes as input reactivity profiles for a
#' transcript region from samples of two groups. First, it regroups the samples
#' into homogeneous and heteregenous sub-groups, which are used to compute the
#' within-group and between-group nucleotide-wise \emph{d} scores. If the
#' region meets the quality criteria, the between- and within-group \emph{d}
#' scores are compared using the Wilcoxon signed-rank test.
#' The resulting p-values quantify the significance of difference in reactivity
#' patterns between the two input groups.
#'
#' @param reps_A Number of replicates of group A.
#' @param reps_B Number of replicates of group B.
#' @param rdf Dataframe of reactivities for each sample. Each column must be labelled as A1, A2, ..., B1, B2, ...
#' @param batches Logical suggesting if replicates of group A and B were performed in batches and are labelled accordingly. If TRUE, a heterogeneous/homogeneous subset may not have multiple samples from the same batch.
#' @param between_combs Dataframe with each column containing groupings of replicates of groups A and B, which will be used to assess between-group variation.
#' @param within_combs Data.frame with each column containing groupings of replicates of groups A or B, which will be used to assess within-group variation.
#' @param check_quality Logical, if TRUE, check regions for quality.
#' @param quality Worst allowed quality for a region to be tested.
#' @param evidence Minimum evidence of increase in variation from within-group comparisons to between-group comparisons for a region to be tested.
#' @return p-value for the tested region (estimated using one-sided Wilcoxon signed rank test) and the median of nucleotide-wise difference of between-group and within-group d-scores.
#'
#' @author Krishna Choudhary
#'
#' @references
#' Choudhary, K., Lai, Y. H., Tran, E. J., & Aviran, S. (2019).
#' dStruct: identifying differentially reactive regions from RNA
#' structurome profiling data. \emph{Genome biology}, 20(1), 1-26.
#'
#' @examples
#' #Load Wan et al., 2014 data
#' data(wan2014)
#'
#' #Run dStruct in the guided mode on first region in wan2014.
#' dStructGuided(wan2014[[1]], reps_A = 2, reps_B = 1)
#' @export
#' @importFrom stats median wilcox.test
dStructGuided <- function(rdf, reps_A, reps_B, batches = FALSE,
                           within_combs = NULL, between_combs= NULL, check_quality = TRUE,
                           quality = "auto", evidence = 0) {

  if ((quality == "auto") & min(c(reps_A, reps_B)) != 1) quality <- 0.5 else if (quality== "auto") quality <- 0.2
  if (is.null(between_combs) | is.null(within_combs)) idcombs <- getCombs(reps_A, reps_B, batches,
                                                                         between_combs, within_combs)
  if (is.null(between_combs)) between_combs <- idcombs$between_combs
  if (is.null(within_combs)) within_combs <- idcombs$within_combs

  d_within <- dCombs(rdf, within_combs)
  d_between <- dCombs(rdf, between_combs)

  if (mean(d_within, na.rm = TRUE) > quality) return(c(NA, NA))
  if (stats::median(d_between - d_within, na.rm = TRUE) < evidence) return(c(NA, NA))

  result <- tryCatch({
    c(pval = stats::wilcox.test(d_within, d_between,
                  alternative = "less", paired= TRUE)$p.value,
      del_d = stats::median(d_between - d_within, na.rm = TRUE)
    )
  }, error= function(e) {
    #Place holder for those transcripts that can't be tested due to error.
    result <- c(pval = NA, del_d= NA)
  })

  return(result)

}
