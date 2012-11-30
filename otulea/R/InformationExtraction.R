## OTULEA UTILITY FUNCTIONS FOR THE "INFORMATION EXTRACTION" PHASE

## EXAMPLES
if (FALSE) {
require(otulea)
## location of global user file
guf <- "../inst/www/data/user/6CKBT/6CKBT.xml" ## later on we rewrite this with system.file 
## tests taken by the user (returned as an XMLNodeSet)
tests <- list.tests(guf)
## selecting one test 
test <- tests[[1]]
## determining the date when the test was taken
test.date(test)
## getting the last test taken
last(tests)
## converting a test to a data.frame
test.df <- test2df(test)
attributes(test.df)$attrs
## converting all tests to a data frame
tests.df <- lapply(tests,test2df)
attributes(tests.df[[1]]) # attributes are still preserved
## getting all items of a test
test.df
## getting the full path of test-result files
userDir <- "../inst/www/data/user/6CKBT"
testresults <- file.path(userDir,test.df$data)
testresults
getMarkings(testresults)
}
## list all tests taken by a user
list.tests <- function(guf) {
  doc <- xmlParse(guf)
  ##doc.root <- xmlRoot(doc)
  tests <- getNodeSet(doc, "//test")
  tests
}

## tell the date a particular test was taken
test.date <- function(test) {
  ans <- strptime(xmlAttrs(test)["timestamp"],
                  format="%Y_%m_%d_%H_%M_%S")
  names(ans) <- NULL
  ans
}

## getting the last test taken
last <- function(tests) {
  tests.date <- do.call("c",lapply(tests,test.date))
  ## finding the index of the last test taken
  tests[[which.max(order(tests.date))]]
}
  
## transforming a test to a data.frame
test2df <- function(test) {
  test.list <- xmlToList(test)
  attrs <- test.list$.attrs
  test.list <- test.list[names(test.list)=="item"] ## *2 possible place for improvement
  test.df <- data.frame(t(as.data.frame(test.list)),stringsAsFactors=FALSE)
  rownames(test.df) <- NULL
  attributes(test.df)$attrs <- attrs
  test.df
}

## getting the marking sections of various testresult files
## and merge them into a data frame containing character strings 
getMarkings <- function(testresults) {
  markings <- lapply(testresults, function(x) {
    x.parse <- xmlParse(x)
    x.marking <- getNodeSet(x.parse, "//marking")
    getNodeSet(x.marking[[1]],"//mark")
  })
  markings.df <- t(as.data.frame(lapply(do.call("c",markings),function(x) c(xmlAttrs(x),mark=xmlValue(x)))))
  rownames(markings.df) <- NULL
  markings.df
}
