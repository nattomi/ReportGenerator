## FOR GETTING ALPHALEVELS ASSOCIATED TO 'A' TYPE EVALUATION MODES

## EXAMPLES
if (FALSE) {
library(otulea)
user <- "6CKBT" ## user id as character string
threshold <- 50 ## percentage
maxListings <- 3 ## maximal number of results listed
getAlphalevels(user,threshold,maxListings)
getAlphalevels(user,threshold,4)
}


## FUNCTION
getAlphalevels <- function(user, threshold, maxListings) {
  ## Information extraction
  ## location of global user file
  userDir <- file.path(usersDir,user)
  guf <- file.path(userDir,paste(user,"xml",sep=".")) ## later on we rewrite this with system.file
  ## tests taken by the user (returned as an XMLNodeSet)
  tests <- list.tests(guf)
  ## getting the last test taken
  tests.last <- last(tests)
  tests.last.df <- test2df(tests.last)
  testresults <- file.path(userDir,tests.last.df$data)
  markings <- getMarkings(testresults)
  
  ## Derivation of results
  ## In all cases we need the alphalist file, so it's
  ## a good idea to load it right in the beginning
  alphalist.df <- alphalist2df(alphalist)
  alphaIDs <- sort(alphalist.df$alphaID)
  ## all tested alphalevels
  thresholds <- tapply(as.numeric(markings[,"mark"]),markings[,"alphalevel"],mean)
  alphas.tested <- names(thresholds)
  ## which alphalevels are above and below the threshold?
  above <- thresholds >= threshold/100
  alphas.above <- alphas.tested[above]
  alphas.below <- alphas.tested[!above]
  ## for A1 and A2 I only need to do an ordering and then filter according to maxListings
  ## but for A3 I also need to lookup values in alphalist.xml
  ind.above <- alphaIDs %in% alphas.above
  ind.above.shift <- rev(rev(c(FALSE,ind.above))[-1])
  ind.tested <- alphaIDs %in% alphas.tested
  ind <- as.logical((!ind.above)*(ind.above + ind.above.shift))
  ## Case A1
  alphas.A1 <- sort(alphas.above,decreasing=TRUE)
  ## Case A2
  alphas.A2 <- sort(alphas.below,decreasing=FALSE)
  ## Case A3
  alphas.A3 <- alphaIDs[ind]
  ## result as list
  alphas <- list(A1=alphas.A1,A2=alphas.A2,A3=alphas.A3)
  ## limit the number of results
  alphas.limited <- lapply(alphas,function(x) head(x,maxListings))
  attributes(alphas.limited) <- as.list(attributes(tests.last.df)$attrs[c("subject","level")])
  alphas.limited
}
