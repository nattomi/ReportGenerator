## PROVIDED THAT WE HAVE A DATA.FRAME AT LEAST WITH COLUMNS
## "userdescription" AND "example" THIS FUNCTION CREATES THE LATEX
## SOURCE NEEDED FOR INCLUSION IN THE MAIN USER FEEDBACK FILE

## EXAMPLE
if (FALSE) {
library(otulea)
library(xtable)
library(tools)
user <- "6CKBT" ## user id as character string
threshold <- 50 ## percentage
maxListings <- 3 ## maximal number of results listed
alphalist.df <- alphalist2df(alphalist)
y <- getAlphalevels(user,threshold,maxListings,alphalist.df)
x <- uncompress(y)$A1
feedback2tex(x)
}

## FUNCTION DEFINITION
feedback2tex <- function(x) {
  x.sub <- x[,c("userdescription","example")]
  xtable(x.sub)
}


