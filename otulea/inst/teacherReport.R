#!/usr/bin/Rscript
args <- commandArgs(TRUE)
if (length(args)==0) {
  cat("Usage: teacherReport.R user\n")
  cat("where\n")
  cat("* user: user Number\n")
  cat("Example: teacherReport.R 6CKBT\n")
} else {
  require(otulea)
  ##require(tools)
  user <- as.character(args[1])
  testresults <- testResults(user)
  ##print(testresults)
  markings <- lapply(testresults,getMarkings)
  ##print(attributes(markings[[1]]))
  ans <- lapply(markings,function(x) {
    rown=dim(x)[1]
    a=attributes(x)$attrs
    b=matrix(rep(a,rown),nrow=rown,byrow=TRUE)
    colnames(b) <- names(a)
    cbind(b,x)
  })
  print(do.call("rbind",ans))
}
