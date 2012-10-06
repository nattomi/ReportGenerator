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
feedback2tex(x,subject, as.character(modes$mode.string[3]), "\\leiter", cellcol)
## END: TEST RUNS

## BEGIN: MAIN TEST
## figuring out what arguments to use
subject2 <- attr(z,"subject")
cellcolor2 <- as.character(cellcolors$color[match(subject,cellcolors$subject)])
for (n in names(z)) {
  row.of.mode <- match(n,modes$mode)
  mode.string2 <- as.character(modes$mode.string[row.of.mode])
  graphics.command2 <- as.character(modes$graphics[row.of.mode])
  sink(paste("../inst/www/feedback/template/",n,".tex",sep=""))
  feedback2tex(z[[n]],subject2,mode.string2,paste("\\",graphics.command2,sep=""),cellcolor2)
  sink()
}
## END: MAIN TEST

## this one just prints it to screen
##setwd("/tmp/otulear/otulea/R")
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
      command2[1] <- paste("\\multicolumn{2}{m{380pt}}{\\Large{",mode.string,"}} & \\multicolumn{1}{l}{\\Large{Beispiel}}\\\\",sep="")
      command2[2] <- ""
      command <- paste(command1,command2)
      pos <- as.list(seq(-1,rownum-1))
      ## this one goes to the title row
      cat("{\\Huge \\textbf{\\underline{",subject,"}}}\n",sep="")
      cat("\\vspace{2em}\n")
      ## setting font size to small
      cat("{\\small\n")
      print(tbl,floating=FALSE,sanitize.text.function = function(x){x},
            include.rownames=FALSE,include.colnames=FALSE,
            hline.after=c(unlist(pos),rownum)[-1],
            add.to.row=list(pos=pos,command=command))
      cat("}\n")
      options(op)
    } else {
      cat("Nothing to display\n")
    }
  }
}
