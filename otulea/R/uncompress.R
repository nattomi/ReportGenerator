## BASED ON THE RESULT OF 'getAlphalevels' AND AN ALPHALIST DATA FRAME
## IT UNCOMPRESSES THE DESIRED COLUMNS AND ROWS OF THE ALPHALIST

## EXAMPLE
if (FALSE) {
library(otulea)
user <- "6CKBT" ## user id as character string
threshold <- 50 ## percentage
maxListings <- 3 ## maximal number of results listed
alphalist.df <- alphalist2df(alphalist)
x <- getAlphalevels(user,threshold,maxListings,alphalist.df)
uncompress(x)
uncompress(x,alphalist.df,c("userdescription","example"))
}

## ARGUMENTS
## x : a result of 'getAlphalevels'
## alphalist.df : alphalist as a data frame
## subset : subset of columns in the alphalist data frame we are interested in

## FUNCTION DEFINITION
uncompress <- function(x,alphalist.df=alphalist2df(alphalist),
                       subset=1:dim(alphalist.df)[2]) {
  ans <- lapply(x,function(x) alphalist.df[match(x,alphalist.df$alphaID),subset])
  attributes(ans) <- attributes(x)
  ans
}
