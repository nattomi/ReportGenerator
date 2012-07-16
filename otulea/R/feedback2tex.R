## PROVIDED THAT WE HAVE A DATA.FRAME AT LEAST WITH COLUMNS
## "userdescription" AND "example" THIS FUNCTION CREATES THE LATEX
## SOURCE NEEDED FOR INCLUSION IN THE MAIN USER FEEDBACK FILE

## EXAMPLE
if (FALSE) {
library(otulea)
##library(xtable)
library(tools)
user <- "6CKBT" ## user id as character string
threshold <- 50 ## percentage
maxListings <- 3 ## maximal number of results listed
alphalist.df <- alphalist2df(alphalist)
y <- getAlphalevels(user,threshold,maxListings,alphalist.df)
x <- uncompress(y)$A1
## this one just prints it to screen
feedback2tex(x)
## this one overwrites template.tex
sink("../inst/feedback/tabular.tex")
feedback2tex(x)
sink()
texi2dvi("../inst/feedback/userfeedback.tex",pdf=TRUE)
}

## FUNCTION DEFINITION
feedback2tex <- function(x) {
  op <- options(warn=-1)
  ## number of rows
  rownum <- dim(x)[1]
  ## subsetting just to make sure that the input is correct
  ## plus adding 'speaker' column
  x.sub <- cbind("\\speaker",x[,c("userdescription","example")])
  colnames(x.sub) <- c("","\\scalebox{0.2}{\notepad} Schreiben","Beispiel")
  ## xtable commands
  tbl <- xtable(x.sub)
  align(tbl) <- "cm{30pt}|m{310pt}|m{310pt}"
  ## commands to add and their position
  command <- rep(c("\\rowcolor{green!10}","\\rowcolor{blue!10}"),length.out=rownum+1)
  pos <- as.list(seq(-1,rownum-1))
  print(tbl,floating=FALSE,sanitize.text.function = function(x){x},
        include.rownames=FALSE,hline.after=0,
        add.to.row=list(pos=pos,command=command))
  options(op)
}
