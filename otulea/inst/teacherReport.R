#!/usr/bin/Rscript
## SETTINGS
X <- c("Lesen","Schreiben","Sprache","Rechnen")
Y <- c(solved="Kannbeschreibungen erfüllt",
       partly="Kannbeschreibungen teilweise erfüllt",
       notsolved="Kannbeschreibungen nicht erfüllt")

args <- commandArgs(TRUE)
##args <- "KFCG1" # this my test user
if (length(args)==0) {
  cat("Usage: teacherReport.R user\n")
  cat("where\n")
  cat("* user: user Number\n")
  cat("Example: teacherReport.R 6CKBT\n")
} else {
  ## REQUIREMENTS
  require(XML)
  require(tools)
  ## transforming a test to a data.frame
  test2df <- function(test) {
    test.list <- xmlToList(test)
    attrs <- test.list$.attrs
    names(attrs) <- paste(names(attrs),"string",sep=".")
    test.list <- test.list[names(test.list)=="item"] ## *2 possible place for improvement
    test.df <- data.frame(t(as.data.frame(test.list)),stringsAsFactors=FALSE)
    rownames(test.df) <- NULL
    attributes(test.df)$attrs <- attrs
    test.df
  }
  ## list all tests taken by a user
  list.tests <- function(guf) {
    doc <- xmlParse(guf)
    ##doc.root <- xmlRoot(doc)
    tests <- getNodeSet(doc, "//test")
    tests
  }
  ## getting testresults
  testResults <- function(user,last=FALSE) {
      ## location of global user file
    userDir <- file.path(usersDir,user)
    guf <- file.path(userDir,paste(user,"xml",sep=".")) ## later on we rewrite this with system.file
    ## tests taken by the user (returned as an XMLNodeSet)
    tests <- list.tests(guf)
    ## apply 'last' filter if requested
    if (last) tests <- last(tests)
    ## getting the last test taken
    tests.df <- lapply(tests,test2df)
    testresults <- lapply(tests.df, function(x) {
      ans <- file.path(userDir,x$data)
      attributes(ans) <- list(attrs=attributes(x)$attrs)
      ans})
    testresults
  }
  ## getting the marking sections of various testresult files
  ## and merge them into a data frame containing character strings
  getMarkings <- function(testresults) {
    markings <- lapply(testresults, function(x) {
      x.parse <- xmlParse(x)
      x.marking <- getNodeSet(x.parse, "//marking")
      getNodeSet(x.marking[[1]],"//mark")
    })
    markings.all <- do.call("c",markings)
    markings.all2 <- lapply(markings.all,function(x) c(xmlAttrs(x)[c("itemnumber","alphalevel")],mark=xmlValue(x)))
    markings.all3 <- lapply(markings.all2,function(x) {
      m <- x[["mark"]]
      if (m=="" | m=="failed") x[["mark"]] <- 0
      x
    })
    markings.df <- as.data.frame(do.call("rbind",markings.all3))
    attributes(markings.df)<- c(attributes(markings.df),attributes(testresults))
    markings.df
  }
  ## converts alphalist.XML to a data.frame  
  alphalist2df <- function(alphalist) {
    if (is.character(alphalist)) alphalist <- xmlInternalTreeParse(alphalist)
    alphalist.list <- xmlToList(alphalist)
    alphalist.list <- alphalist.list[names(alphalist.list)=="alphanode"]
    ans <- data.frame(t(as.data.frame(alphalist.list)),stringsAsFactors=F)
    rownames(ans) <- NULL
    ans
  }

  ## MAIN
  ## Layer 1: xml to tabular form


  user <- as.character(args[1])
  testresults <- testResults(user)
  markings <- lapply(testresults,getMarkings)
  layer0 <- lapply(markings,function(x) {
    rown=dim(x)[1]
    a=attributes(x)$attrs
    b=matrix(rep(a,rown),nrow=rown,byrow=TRUE)
    colnames(b) <- names(a)
    cbind(b,x)
  })
  ##layer0
  layer1 <- do.call("rbind",layer0)[,c(c("timestamp.string","subject.string","level.string","itemnumber","alphalevel","mark"))]
  ##layer1$mark[layer1$mark==""] <- 0 # we don't want any empty mark value
  ##layer1$mark[layer1$mark=="failed"] <- 0 # we don't want "failed" as a mark value
  ##layer1
  ## Layer 2: sort by subject,alphalevel,itemnumber, then report last 2 marks for each itemnumber
  bysubject <- by(layer1[,c(1,4,5,6)],as.character(layer1$subject.string),function(x) x)
  ##head(bysubject$Lesen)
  layer2.list <- lapply(bysubject,function(x) { # sorts elements by subject
    y <- by(x[,c(1,2,4)],as.character(x$alphalevel),function(x) x) # sorts elements belonging to a subject by ability description (alphalevel)
    lapply(y,function(x) { # calculating last two marks 
      byitem <- by(x[,c(1,3)],as.character(x$itemnumber),function(x) {
        x.time <- strptime(as.character(x$timestamp.string),format="%Y_%m_%d_%H_%M_%S",tz="GMT")
        x.time.bylatest <- order(x.time,decreasing=TRUE)
        as.integer(as.character(x$mark[x.time.bylatest]))
      })
      sapply(byitem,function(x) c(before.latest=x[2],latest=x[1]))
    })
  })
  ##layer2.list$Lesen
  layer2 <- lapply(layer2.list,function(z) { # calculating overall tendency and category for each alphalevel
    lapply(z,function(y) {
      tendencyvector <- apply(y,2,function(x) x[2]-x[1])
      ans <- rbind(y,tendency=tendencyvector)
      ## calculating the overall tendency
      tv0 <- tendencyvector[!is.na(tendencyvector)]
      tv <- ifelse(length(tv0) > 0,sum(tv0),NA)
      ## add category as attribute
      latest <- y["latest",]
      ctg <- 10 
      if (any(latest==0)) { 
        ctg <- ifelse(all(latest==0),0,5)
      }
      attributes(ans) <- c(attributes(ans),list(ctg=ctg,tendency=sign(tv)))
      ans
    })
  })
  ## group alphalevels by category
  layer3 <- lapply(layer2,function(x) lapply(c(solved=10,partly=5,notsolved=0),function(i) x[sapply(x,function(x) attributes(x)$ctg==i)]))
  systime <- Sys.time()
  baseName <- paste(user,format(systime,format="%Y%m%d_%H_%M_%S"),sep="_")
  baseName <- "systime" # for testing only
  baseName <- paste(baseName,"teacher",sep="_")
  pdfName <- paste(baseName,"pdf",sep=".")
  texName <- paste(baseName,"tex",sep=".")
  userDir <- file.path(usersDir, user) # this one is quite redundant here, but quicker than rewriting a bunch of functions
  userDir <- "/tmp" # for testing
  tmpdir <- file.path(userDir,baseName)
  if (!file.exists(tmpdir)) dir.create(tmpdir) # just to make sure
  ## creating tex tabulars
  alphalist.df <- alphalist2df(alphalist)
  for (y in Y) {
    catname <- names(Y)[Y==y]
    sink(file.path(tmpdir,paste(catname,".tex",sep="")))
    cat("\\textline[t]{",user,"}{",y,"}{Datum: ",format(systime,format="%d.%m.%Y"),"}\n",sep="")
    cat("{\\scriptsize\\noindent")
    for (x in X) {
      cat("\\colorbox{",x,"-",catname,"}{\\begin{minipage}{.25\\textwidth}\n",sep="")
      cat("\\hasab{\\begin{tabular}{@{}p{.3cm}@{}|@{}p{3.5cm}@{}|@{}p{3.5cm}@{}}\n")
      cat("\\hline\n")
      cat("\\multicolumn{3}{c}{\\textbf{",x,"}}\\\\\n",sep="")
      cat("\\hline\n")
      cat("\\multicolumn{2}{@{}l|}{\\textbf{Kannbeschreibung}} & \\textbf{Aufgabe} \\\\\n")
      cat("\\hline\n")
      xy <- layer3[[x]][[catname]]
      item <- names(xy)[1]
      for (item in names(xy)) {
        i.alphaID <- match(item,alphalist.df$alphaID)
        tab <- xy[[item]]
        ctg <- attributes(tab)$ctg
        CN <- colnames(tab)
        checkmarks <- sapply(tab["latest",CN],function(x) ifelse(x,"\\checkmark",""))
        cell1 <- alphalist.df[i.alphaID,"description"]
        cell1 <- gsub("μ","$\\\\mu$",cell1) # replacing out-of-range unicode character
        cell2 <- paste(paste(gsub("_","\\\\textunderscore ",CN),checkmarks,sep=""),collapse=", ")
        tend.int <- attributes(tab)$tendency
        tend <- "-"
        if (!is.na(tend.int)) {
          tend <- ifelse(tend.int > 0,"$\\Uparrow$",
                         ifelse(tend.int==0,"$\\Rightarrow$","$\\Downarrow$"))
        }
        cat(tend,"&",cell1,"&",cell2,"\\\\\n")
        cat("\\hline\n")
      }
      cat("\\end{tabular}}\n")
      cat("\\end{minipage}}%\n")
    }
    cat("}\n")
    sink()
  } # for
  
  ## copying template file to temporary directory 
  file.copy(file.path(dir.template,"feedback.tex"),
            file.path(tmpdir,texName))
  ## running pdflatex                                                     
  wd.orig <- getwd()                                                      
  setwd(tmpdir)                                                           
  texi2dvi(texName,pdf=TRUE)                                              
  setwd(wd.orig)
  ## moving resulting pdf to user's dir and
  ## deleting temporary directory
  file.copy(file.path(tmpdir,pdfName),userDir)                            
  unlink(tmpdir,recursive=TRUE)
  ## printing name of xml file to screen
  cat(pdfName)
} # else

