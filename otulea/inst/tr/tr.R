#!/usr/bin/Rscript
## SETTINGS
X <- c("Lesen","Schreiben","Sprache","Mathe")
Y <- c("0")
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
##CLINE
##cline(CLINE[4,])
## MAIN
dat0 <- read.csv("tr.csv")
dat <- transform(dat0,ast=paste(aufgabe,score,sep="_"),nch=nchar(as.character(description)))
##head(dat)

state.list <- by(dat,dat$state,function(x) x)
## printing table
cat("\\begin{tabular}{|p{.02\\textwidth}|p{.2\\textwidth}|p{.02\\textwidth}|p{.2\\textwidth}|p{.02\\textwidth}|p{.2\\textwidth}|p{.02\\textwidth}|p{.2\\textwidth}|}\n")
##cat("\\hline\n")
##state <- state.list[[1]]
##y <- Y[1]
for (y in Y) {
  state <- state.list[[y]]
  cat("\\hline\n")
  dimension.list <- by(state,state$type,function(x) {
    y <- x[,-match(c("type","aufgabe","score","state"),names(x))]
    y
  })
  M <- sapply(dimension.list,function(x) dim(x)[1])
  K <- max(M)-M
  TABL.list <- lapply(X,function(y) {
    tabl <- dimension.list[[y]]
    repl <- K[[y]]
    if (repl > 0) {
      i <- which.max(tabl$nch)
      tabl.i <- tabl[i,]
      for (j in 1:repl) {
        tabl <- rbind(tabl,tabl.i)
      }
    }
    tabl <- tabl[order(tabl$ast,tabl$description),]
    tabl[,c("ast","description")]
  })
  TABL <- do.call("cbind",TABL.list)
  TABL.multirow <- as.data.frame(lapply(TABL,multirow))
  d <- dim(TABL)
  CLINE <- matrix(FALSE,nrow=d[1],ncol=d[2])
  for (i in 1:d[1]) {
    cline <- "\\..."
    for (j in 1:d[2]) {
      cellcontent <- " "
      nrows <- TABL.multirow[i,j]
      if (nrows>0) CLINE[nrows+i-1,j] <- TRUE
      cellcontent.ij <- as.character(TABL[i,j])
      cellcontent.ij <- strsplit(cellcontent.ij,"_")[[1]][1]
      if (nrows > 0) {
        pwidth <- ifelse(j %% 2==0,0.2,0.02)
        cellcontent <- paste("\\parbox{",pwidth,"\\textwidth}{",cellcontent.ij,"}",sep="")
        if (nrows > 1) {
          cellcontent <- paste("\\multirow{",nrows,"}{*}{",cellcontent,"}",sep="")
        }
      }
      cat(cellcontent)
      separator <- ifelse(j < d[2]," & "," \\\\\n")
      cat(separator)
    }
    cat(cl(CLINE[i,]),"\n")
  }
  cat("\\hline\n")
}
cat("\\end{tabular}\n")
