require(otulea)
## location of global user file
guf <- "../inst/www/data/user/6CKBT/6CKBT.xml"
userDir <- "../inst/www/data/user/6CKBT"

## tests taken by the user (returned as an XMLNodeSet)
tests <- list.tests(guf)
tests
tests.df <- lapply(tests,test2df)
## the same data frame, but with full paths to testresult files
tests.df.full <- lapply(tests.df,function(x) {
  x$data <- file.path(userDir,x$data)
  x
})
tests.df.full






## selecting one test
attributes(tests.df.full[[1]])$attrs


test <- tests[[1]]
testresults(tests[[1]])

userDir <- "../inst/www/data/user/6CKBT"
testresults <- file.path(userDir,tests.df[[1]]$data)



testresults
getMarking(testresults[1])
lapply(testresults,getMarking)
## getting testresults from all tests
testresults.all <- lapply(tests.df,function(x) file.path(userDir,x$data))
## we can convert it to other forms
unlist(testresults.all)
getMarkings(testresults)
