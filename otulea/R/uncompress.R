## BASED ON THE RESULT OF 'getAlphalevels' AND AN ALPHALIST DATA FRAME
## IT UNCOMPRESSES THE DESIRED COLUMNS AND ROWS OF THE ALPHALIST

## EXAMPLE
if (FALSE) {
library(otulea)
library(xtable)
library(tools)
user <- "6CKBT" ## user id as character string
threshold <- 50 ## percentage
maxListings <- 3 ## maximal number of results listed
alphalist.df <- alphalist2df(alphalist)
x <- getAlphalevels(user,threshold,maxListings,alphalist.df)
uncompress(x)
x <- uncompress(x,alphalist.df,c("userdescription","example"))
sink("/tmp/report.tex")
uncprsd2tex(x)
sink()
currentWD <- getwd()
setwd("/tmp")
texi2dvi("/tmp/report.tex",pdf=TRUE)
setwd(currentWD)
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

uncprsd2tex <- function(x) {
  cat("\\documentclass[landscape]{article}","\n")
  cat("\\usepackage[utf8]{inputenc}","\n")
  ##cat("\\usepackage[german]{babel}","\n") ## it might be useful for displaying quotation marks correctly
  cat("\\usepackage[top=2.5cm, bottom=2.5cm, left=2.5cm, right=2.5cm]{geometry}","\n")
  cat("\\begin{document}","\n")
  ## I want no page numbering
  cat("\\pagestyle{empty}","\n")
  ## start of main content
  for (i in paste("A",1:3,sep="")) {
    y <- x[[i]]
    title <- as.character(titles$title[match(i,titles$mode)])
    cat("\\section*{",title,"}","\n",sep="")
    if (dim(y)[1] > 0) {
      tab <- xtable(y)
      print(tab,include.rownames=FALSE)
     } else {
      cat("Nothing to display","\n")
    }
    cat("\\newpage","\n")
  }
  ## end of main content
  cat("\\end{document}","\n")
}
