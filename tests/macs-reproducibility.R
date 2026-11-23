# Use fresh R processes so results cannot depend on a single process's heap.
library(AlphaSimR)
worker <- function() {
  library(AlphaSimR)
  args <- commandArgs(TRUE)
  seeds <- c(71L, 2054428010L)
  if (args[2]=="reverse") seeds <- rev(seeds)
  if (args[3]=="noise") {
    allocation_noise <- replicate(10000, paste(sample(letters,40,TRUE),collapse=""))
    gc()
  }
  results <- list()
  for (seed in seeds) {
    set.seed(seed)
    founders <- runMacs2(nInd=4,nChr=2,Ne=1000,bp=10000,
      genLen=.1,mutRate=1e-7,histNe=NULL,histGen=NULL,
      ploidy=4L,nThreads=as.integer(args[4]))
    results[[as.character(seed)]] <- list(geno=founders@geno,map=founders@genMap)
  }
  saveRDS(results,args[1])
}
script <- tempfile(fileext=".R")
writeLines(c("worker <-",deparse(worker),"worker()"),script)
outputs <- character()
reference <- NULL
for (run in seq_len(4)) {
  output <- tempfile(fileext=".rds")
  outputs <- c(outputs,output)
  status <- system2(file.path(R.home("bin"),"Rscript"),
    c("--vanilla",shQuote(script),shQuote(output),
      if (run%%2==0) "reverse" else "normal",
      if (run>2) "noise" else "clean",if (run==4) "2" else "1"),stdout=FALSE)
  stopifnot(status==0L)
  result <- readRDS(output)
  if (is.null(reference)) reference <- result
  for (seed in names(reference)) stopifnot(identical(result[[seed]],reference[[seed]]))
}
stopifnot(!identical(reference[[1]],reference[[2]]))
unlink(c(script,outputs))
cat("Fresh-process, reversed-order, allocation and thread-count replay checks passed.\n")
