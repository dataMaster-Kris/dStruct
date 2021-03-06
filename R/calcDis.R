#' @title Calculates d score.
#'
#' @description \emph{d} score of a nucleotide is a measure of dissimilarity of its
#' normalized reactivity scores. Consider a transcript and its reactivity profiles
#' from a group of samples. Then, the \emph{d} score of a nucleotide is \eqn{(2/\pi)}
#' times the arc-tangent of the ratio of the sample standard deviation of its
#' reactivities to their mean.
#'
#' @param x A numeric vector or matrix.
#' @return If input is a numeric vector, a number is returned. For a matrix, a numeric vector is returned.
#'
#' @author Krishna Choudhary
#'
#' @references
#' Choudhary, K., Lai, Y. H., Tran, E. J., & Aviran, S. (2019).
#' dStruct: identifying differentially reactive regions from RNA
#' structurome profiling data. \emph{Genome biology}, 20(1), 1-26.
#'
#' Choudhary K, Shih NP, Deng F, Ledda M, Li B, Aviran S.
#' Metrics for rapid quality control in RNA structure probing experiments.
#' \emph{Bioinformatics}. 2016; 32(23):3575–3583.
#'
#' @examples
#' #Lower standard deviation of reactivites results in lower d-score.
#' calcDis(rnorm(10, 1, 0.2))
#' calcDis(rnorm(10, 1, 0.6))
#' @export
#' @importFrom stats sd
calcDis <- function(x) {
  dScore <- function(y) 2*(atan(abs(stats::sd(y)/mean(y))))/pi
  if (is.numeric(x)) return(dScore(x))
  return(apply(x, 1, function(y) dScore(y)))
}
