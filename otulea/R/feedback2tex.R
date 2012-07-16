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
  command <- rep(c("\\rowcolor{green!10}","rowcolor{bule!10}"),length.out=rownum+1)
  pos <- as.list(seq(-1,rownum-1))
  print(tbl,floating=FALSE,sanitize.text.function = function(x){x},
        include.rownames=FALSE,hline.after=0,
        add.to.row=list(pos=pos,command=command))
}


attributes(tbl)
