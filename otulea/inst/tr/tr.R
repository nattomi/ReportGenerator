#!/usr/bin/Rscript
## SETTINGS
X <- c("Lesen","Schreiben","Sprache","Mathe")
Y <- c("10","5","0")
Y.string <- c("Kannbeschreibungen erfüllt","Kannbeschreibungen teilweise erfüllt","Kannbeschreibungen nicht erfüllt")
user <- "X0AT2"
datum <- "14.2.2012."

## ROUTINES
multirow <- function(x) {
  l <- length(x)
  ans <- rep(0,l)
  y <- c(".",x)
  j <- 1
  for (i in 1:l) {
    if (y[i+1]!=y[i]) j <- i
    ans[j] <- ans[j]+1
  }
  ans
}

multirow.rev <- function(x) {
  ans <- rev(multirow(rev(x)))
  for (i in seq_along(ans)) {
    if (ans[i] > 1) ans[i] <- -ans[i]
  }
  ans
}

cl <- function(x) {
  num <- seq_along(x)[x]
  paste("\\cline{",num,"-",num,"}",sep="",collapse="")
}





## MAIN
dat0 <- read.csv("tr.csv")
dat <- transform(dat0,ast=paste(aufgabe,score,sep="_"),nch=nchar(as.character(description)))
head(dat)

state.list <- by(dat,dat$state,function(x) x)
#state.list
## printing table
cat("\\begin{tabular}{|m{6mm}|l|l|l|l|}\n")
cat("\\multicolumn{1}{l}{} & \\multicolumn{3}{l}{Teilnehmer/Teilnehmerin: \\textbf{",user,"}} & \\multicolumn{1}{r}{Datum: ",datum,"}\\\\\n",sep="")
cat("\\hhline{~|----}\n")
cat("\\multicolumn{1}{l|}{} &", paste("\\cellcolor{frame}",X,sep="",collapse=" & "),"\\\\\n")
cat("\\hline\n")
for (j in seq_along(Y)) {
  y <- Y[j]; y.string <- Y.string[j]
  cat("\\cellcolor{frame}\n")
  cat("\\vspace{.5em}\n")
  cat("\\begin{sideways}\\parbox{9em}{\\centering ",y.string,"}\\end{sideways} &\n",sep="")
  cat(paste("\\cellcolor{",X,"-",y,"}valami",sep="",collapse=" & "),"\\\\\n")
  cat("\\hline\n")
}
cat("\\end{tabular}\n")


if (FALSE) {
  
cat("\\begin{tabular}{c|c|p{.17\\textwidth}|c|p{.17\\textwidth}|c|p{.17\\textwidth}|c|p{.17\\textwidth}|}\n")
cat("\\hhline{~|*{8}{-}}\n")
cat("% First line of header\n")
cat("& \\multicolumn{4}{l}{\\cellcolor{frame}Teilnehmer/Teilnehmerin: \\textbf{X0AT2}} & \\multicolumn{4}{r}{\\cellcolor{frame}Datum: 14.2.2012}\\\\\n")
cat("\\hhline{~|*{8}{-}}\n")
cat("% Second line of header\n")
thead1 <- paste("\\cellcolor{frame}",rep("Aufgabe",3),sep="")
thead2 <- paste("\\cellcolor{frame}",X,sep="")
cat("&",paste(thead1,thead2,sep=" & ", collapse=" & "),"\\\\\n")
for (y in Y) {
  state <- state.list[[y]]
  cat("\\hline\n")
  cat("% Ability level",y,"\n")
  dimension.list <- by(state,state$type,function(x) {
    y <- x[,-match(c("type","aufgabe","score","state"),names(x))]
    y
  })
  M <- sapply(dimension.list,function(x) dim(x)[1])
  K <- max(M)-M
  TABL.list <- lapply(X,function(x) {
    tabl <- dimension.list[[x]]
    repl <- K[[x]]
    if (repl > 0) {
      i <- which.max(tabl$nch)
      tabl.i <- tabl[i,]
      for (j in 1:repl) {
        tabl <- rbind(tabl,tabl.i)
      }
    }
    tabl <- tabl[order(tabl$ast,tabl$description),]
    tabl <- tabl[,c("ast","description")]
    attributes(tabl) <- c(attributes(tabl),list(color=paste(x,y,sep="-")))
    tabl
  })
  TABL <- do.call("cbind",TABL.list)
  TABL.multirow <- as.data.frame(lapply(TABL,multirow.rev))
  COLOR.list <- lapply(TABL.list,function(x) {
    d <- dim(x)
    matrix(attributes(x)$color,nrow=d[1],ncol=d[2])
  })
  COLOR <- do.call("cbind",COLOR.list)
  d <- dim(TABL)
  CLINE <- matrix(FALSE,nrow=d[1],ncol=d[2])
  for (i in 1:d[1]) {
    cellcontent.base <- "\\cellcolor{frame} "
    cellcontent <- cellcontent.base
    if (i==d[1]) {
      cellcontent <- paste(cellcontent.base,"\\multirow{",-d[1],"}{*}{\\rotatebox[origin=c]{90}{\\parbox{8cm}{",Y.string[match(y,Y)],"}}}",sep="")
    }
    cat(cellcontent,"& ")
    for (j in 1:d[2]) {
      cellcontent.base <- paste("\\cellcolor{",COLOR[i,j],"}",sep="")
      cellcontent <- cellcontent.base
      nrows <- TABL.multirow[i,j]
      cellcontent.ij <- as.character(TABL[i,j])
      cellcontent.ij <- strsplit(cellcontent.ij,"_")[[1]][1]
      if (abs(nrows) > 0) {
        CLINE[nrows+i-1,j] <- TRUE
        pwidth <- ifelse(j %% 2==0,0.17,0.02)
        cellcontent <- paste(cellcontent.base,"\\parbox{",pwidth,"\\textwidth}{",cellcontent.ij,"}",sep="")
        if (abs(nrows) > 1) {
          cellcontent <- paste(cellcontent.base,"\\multirow{",nrows,"}{*}{",cellcontent,"}",sep="")
        }
      }
      cat(cellcontent)
      separator <- ifelse(j < d[2]," & "," \\\\\n")
      cat(separator)
    }
    cat(cl(c(FALSE,CLINE[i,])),"\n")
  }
  cat("\\hline\n")
}
cat("\\end{tabular}\n")
}
