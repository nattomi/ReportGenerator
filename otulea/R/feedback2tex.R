## PROVIDED THAT WE HAVE A DATA.FRAME AT LEAST WITH COLUMNS
## "userdescription" AND "example" THIS FUNCTION CREATES THE LATEX
## SOURCE NEEDED FOR INCLUSION IN THE MAIN USER FEEDBACK FILE

## EXAMPLE
if (FALSE) {
library(otulea)
##library(xtable)
library(tools)
## BEGIN: PRECOMPUTATIONS
user <- "6CKBT" ## user id as character string
threshold <- 50 ## percentage
maxListings <- 3 ## maximal number of results listed
alphalist.df <- alphalist2df(alphalist)
y <- getAlphalevels(user,threshold,maxListings,alphalist.df)
z <- uncompress(y)
z
## END: PRECOMPUTATIONS

## BEGIN: DEFINING ARGUMENTS
x <- z$A1
subject <- "Schreiben"
mode.string <- "Das kann ich!"
graphics.command <- "\\haken"
cellcol <- "f2f2cb"
## END: DEFINING ARGUMNETS

## BEGIN: TEST RUNS
feedback2tex(x,subject, mode.string, graphics.command, cellcol)
## changing mode string and graphics
feedback2tex(x,subject, as.character(titles$title[3]), "\\leiter", cellcol)
## END: TEST RUNS

## BEGIN: MAIN TEST
## figuring out what arguments to use
subject2 <- attr(z,"subject")
cellcolor2 <- as.character(cellcolors$color[match(subject,cellcolors$subject)])
for (n in names(z)) {
  mode.string2 <- as.character(titles$title[match(n,titles$mode)])
  sink(paste("../inst/www/feedback/template/",n,".tex",sep=""))
  feedback2tex(z[[n]],subject2,mode.string2,"\\haken",cellcolor2)
  sink()
}
## END: MAIN TEST

##ind.col <- match(tolower(sj),tolower(cellcolors$subject))
##cellcol <- as.character(cellcolors$color[ind.col])
##x <- uncompress(y)$A1
##y
## this one just prints it to screen
##setwd("/tmp/otulear/otulea/R")
##feedback2tex(x)
## this one overwrites template.tex
##sink("../inst/www/feedback/template/tabular_A1.tex")
##feedback2tex(x$A1)
##sink()
##sink("../inst/www/feedback/template/tabular_A2.tex")
##feedback2tex(x$A2,rep(cellcol,2))
##sink()
##sink("../inst/www/feedback/template/tabular_A3.tex")
##feedback2tex(x$A3,rep(cellcol,2))
##sink()
##3+3
##feedback2tex()

##setwd("../inst/feedback/")
## Sys.setenv(TEXINPUTS="/usr/local/texlive/2012/texmf-dist/tex/latex/background")
##texi2pdf("userfeedback.tex")
}

## FUNCTION DEFINITION
feedback2tex <- function(x,subject, mode.string, graphics.command, cellcol) {
  if (missing(x)) {
    ## if the first argument is missing then we enter into demo mode
    cat(paste(paste(template_default,collapse="\n"),"\n"))
  } else {
    ## declare cellcolor - FIXME: should it be here or in the master file?
    cat("\\definecolor{cellcol}{HTML}{",toupper(cellcol),"}\n",sep="")
    ## number of rows
    rownum <- dim(x)[1]
    if (rownum > 0) {
      op <- options(warn=-1)
      ## subsetting just to make sure that the input is correct
      ## plus adding 'speaker' column
      x.sub <- cbind(paste("\\scalebox{0.8}{",graphics.command,"}",sep=""),x[,c("userdescription","example")])
      ## xtable commands
      tbl <- xtable(x.sub)
      align(tbl) <- "c|m{80pt}|m{300pt}|m{300pt}|"
      ## commands to add and their position
      command1 <- rep("\\rowcolor{cellcol}",length.out=rownum+1)
      command2 <- rep("\\hline",length.out=rownum+1)
      command1[1] <- ""
      ## Title associated to selected mode
      mode.title <- as.character(titles$title[match(mode,titles$mode)])
      command2[1] <- paste("\\multicolumn{2}{l}{\\Large{",mode.title,"}} & \\multicolumn{1}{l}{\\Large{Beispiel}}\\\\",sep="")
      command2[2] <- ""
      command <- paste(command1,command2)
      pos <- as.list(seq(-1,rownum-1))
      print(tbl,floating=FALSE,sanitize.text.function = function(x){x},
            include.rownames=FALSE,include.colnames=FALSE,
            hline.after=c(unlist(pos),rownum)[-1],
            add.to.row=list(pos=pos,command=command))
      options(op)
    } else {
      cat("Nothing to display\n")
    }
  }
}
