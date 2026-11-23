# Run directly with Rscript or as part of R CMD check.
library(AlphaSimR)
for (ploidy in c(2L, 4L)) {
  for (inbred in c(FALSE, TRUE)) {
    for (mutation_rate in c(0, 1e-15)) {
      set.seed(71)
      founders <- runMacs2(nInd=4, nChr=2, Ne=100, bp=100,
        genLen=0, mutRate=mutation_rate, histNe=NULL, histGen=NULL,
        ploidy=ploidy, inbred=inbred, nThreads=1L)
      stopifnot(founders@nInd==4L, founders@ploidy==ploidy,
        all(founders@nLoci==0L), all(is.finite(founders@centromere)),
        all(lengths(founders@genMap)==0L))
      for (chromosome in seq_len(founders@nChr)) {
        stopifnot(identical(dim(founders@geno[[chromosome]]), c(0L,ploidy,4L)))
      }
    }
  }
}
cat("Eight zero-site configurations passed, including positive mutation rates.\n")
