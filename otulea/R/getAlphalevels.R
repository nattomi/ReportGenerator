## FOR GETTING ALPHALEVELS ASSOCIATED TO 'A' TYPE EVALUATION MODES

## EXAMPLES
if (FALSE) {
library(otulea)
user <- "KFCG1" ## user id as character string
threshold <- 50 ## percentage
maxListings <- 3 ## maximal number of results listed
alphalist.df <- alphalist2df(alphalist)

getAlphalevelsA(user,threshold,maxListings,alphalist.df)
getAlphalevelsA(user,threshold,4,alphalist.df)
}


## FUNCTION
getAlphalevelsA <- function(user, threshold, maxListings,
                           alphalist.df) {
  ## Information extraction
  ## getting testresults - FIXME: adding a mode argument?
  testresults <- testResults(user,TRUE)
  ## marking
  markings <- lapply(testresults,getMarkings)
  ## Derivation of results
  ## getting alphaID-s from the alphalist data frame
  alphaIDs <- sort(alphalist.df$alphaID)
  ## all tested ability levels
  thresholds <- tapply(as.integer(as.character(markings[[1]][,"mark"])),as.character(markings[[1]][,"alphalevel"]), mean)
  thresholds
  markings[[1]][markings[[1]][,"alphalevel"]=="1.3.2.1","mark"]
  10/16
  
  alphas.tested <- names(thresholds)
  ## which ability levels are above and below the threshold?
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
  ## passing 'subject' and 'level' as attribute
  attrs <- lapply(testresults,attributes)[[1]][["attrs"]]
  attr(alphas.limited,"subject") <- attrs[["subject.string"]]
  attr(alphas.limited,"level") <- attrs[["level.string"]]
  alphas.limited
}


getAlphalevelsB <- function(user, threshold, maxListings,
                           alphalist.df) {
  ## It is still a dummy function
  ## Information extraction
  ## getting testresults - FIXME: adding a mode argument?
  testresults <- testResults(user,TRUE)
  ## marking
  markings <- lapply(testresults,getMarkings)
  ## Derivation of results
  ## getting alphaID-s from the alphalist data frame
  alphaIDs <- sort(alphalist.df$alphaID)
  ## all tested alphalevels
  thresholds <- tapply(as.numeric(markings[[1]][,"mark"]),markings[[1]][,"alphalevel"],mean)
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
  ## passing 'subject' and 'level' as attribute
  attrs <- lapply(testresults,attributes)[[1]]
  attr(alphas.limited,"subject") <- attrs[["subject"]]
  attr(alphas.limited,"level") <- attrs[["level"]]
  alphas.limited
}
