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
  testResults <- function(userDir,guf,last=FALSE) {
    ## tests taken by the user (returned as an XMLNodeSet)
    tests <- list.tests(guf)
    ## apply 'last' filter if requested
    if (last) tests <- last(tests)
    ## getting the last test taken
    tests.df <- lapply(tests,test2df)
    testresults <- lapply(tests.df, function(x) {
      ans <- file.path(userDir,x$data)
      names(ans) <- x$iname
      attributes(ans) <- c(attributes(ans),list(attrs=attributes(x)$attrs))
      ans})
    testresults
  }
  ## getting the marking sections of various testresult files
  ## and merge them into a data frame containing character strings
  getMarkings <- function(testresult) {
    markings <- lapply(testresult, function(x) {
      x.parse <- xmlParse(x)
      x.marking <- getNodeSet(x.parse, "//marking")
      getNodeSet(x.marking[[1]],"//mark")
    })
    markings.all <- c()
    for (n in names(markings)) {
      markings.n <- markings[[n]]
      ans.n <- lapply(markings.n,function(x) c(task=n,xmlAttrs(x)[c("itemnumber","alphalevel")],mark=xmlValue(x)))
      ans.n <- do.call("rbind",ans.n)
      markings.all <- rbind(markings.all,ans.n)
    }
    ## this is for sanitizing erronous data
    marks <- markings.all[,"mark"]
    markings.all[marks=="" | marks=="failed","mark"] <- 0
    markings.df <- as.data.frame(markings.all)
    attributes(markings.df)<- c(attributes(markings.df),attributes(testresult)$attrs)
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
  ## Sanitizing out-of-range characters
  sanitize <- function(x) {
    x <- gsub("μ","$\\\\mu$",x)
    x <- gsub("«","\\\\guillemotleft ",x)
    x <- gsub("»","\\\\guillemotright ",x)
    x
  }
  
  ## MAIN
  ## Layer 1: xml to tabular form
  user <- as.character(args[1])
  userDir <- file.path(usersDir,user) # the user's folder
  guf <- file.path(userDir,paste(user,"xml",sep=".")) # global user file
  testresults <- testResults(userDir,guf)
  markings <- lapply(testresults,getMarkings)
  layer0 <- lapply(markings,function(x) {
    rown <- nrow(x)
    a <- attributes(x)[c("timestamp.string","subject.string","level.string")]
    b <- matrix(rep(a,rown),nrow=rown,byrow=TRUE)
    colnames(b) <- names(a)
    cbind(b,x)
  })
  layer0
  layer1 <- do.call("rbind",layer0)[,c(c("timestamp.string","subject.string","level.string","itemnumber","alphalevel","mark","task"))]
  ## Layer 2: sort by subject,alphalevel,itemnumber, then report last 2 marks for each itemnumber
  bysubject <- by(layer1[,c(1,7,4,5,6)],as.character(layer1$subject.string),function(x) x)
  ##head(bysubject$Lesen)
  bysubject
  layer2.list <- lapply(bysubject,function(x) { # sorts elements by subject
    y <- by(x[,c(1,2,3,5)],as.character(x$alphalevel),function(x) x) # sorts elements belonging to a subject by ability description (alphalevel)
    lapply(y,function(x) { # calculating last two marks 
      byitem <- by(x[,c(1,2,4)],as.character(x$itemnumber),function(x) {
        x.time <- strptime(as.character(x$timestamp.string),format="%Y_%m_%d_%H_%M_%S",tz="GMT")
        x.time.bylatest <- order(x.time,decreasing=TRUE)
        x[x.time.bylatest,c("task","mark")]
      })
      ans <- sapply(byitem,function(x) {
        c(latest=as.character(x[1,"mark"]),
          before.latest=as.character(x[2,"mark"]),
          task=as.character(x[1,"task"]))
      })
      ans
    })
  })
  layer2.list$Sprache
  layer2 <- lapply(layer2.list,function(z) { # calculating overall tendency, category and checkmark for each alphalevel
    lapply(z,function(y) {
      ## calculating associated tasks and checkmarks
      marks.latest <- as.integer(as.character(y["latest",]))
      marks.before.latest <- as.integer(as.character(y["before.latest",]))
      tasks <- tapply(marks.latest,y["task",],all)
      ## adding tendency and category as attribute
      tendencyvector <- marks.latest-marks.before.latest
      ## calculating the overall tendency
      tv0 <- tendencyvector[!is.na(tendencyvector)]
      tv <- ifelse(length(tv0) > 0,sum(tv0),NA)
      ## calculating the category attribute
      ctg <- 10 
      if (any(marks.latest==0)) { 
        ctg <- ifelse(all(marks.latest==0),0,5)
      }
      ## return
      attributes(tasks) <- c(attributes(tasks),list(ctg=ctg,tendency=sign(tv)))
      tendencyvector
      tasks
    })
  })
  layer2$Schreiben
  ## group alphalevels by category
  layer3 <- lapply(layer2,function(x) lapply(c(solved=10,partly=5,notsolved=0),function(i) x[sapply(x,function(x) attributes(x)$ctg==i)]))
  systime <- Sys.time()
  baseName <- paste(user,format(systime,format="%Y%m%d_%H_%M_%S"),sep="_")
  baseName <- "systime" # for testing only
  baseName <- paste(baseName,"teacher",sep="_")
  pdfName <- paste(baseName,"pdf",sep=".")
  texName <- paste(baseName,"tex",sep=".")
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
      cat("\\hasab{\\begin{tabular}{@{\\hspace{.2em}}p{1em}@{\\hspace{.1em}}|@{\\hspace{.4em}}p{14em}@{\\hspace{.4em}}|@{\\hspace{.4em}}p{9.2em}@{\\hspace{.4em}}}\n")
      cat("\\hline\n")
      cat("\\multicolumn{3}{c}{\\textbf{",x,"}}\\\\\n",sep="")
      cat("\\hline\n")
      cat("\\multicolumn{2}{@{\\hspace{.4em}}l|@{\\hspace{.4em}}}{\\textbf{Kannbeschreibung}} & \\textbf{Aufgabe} \\\\\n")
      cat("\\hline\n")
      xy <- layer3[[x]][[catname]]
      ##item <- names(xy)[1] # for testing
      for (item in names(xy)) {
        i.alphaID <- match(item,alphalist.df$alphaID)
        tab <- xy[[item]]
        ctg <- attributes(tab)$ctg
        CN <- names(tab)
        checkmarks <- sapply(tab,function(x) ifelse(x,"\\checkmark",""))
        cell1 <- alphalist.df[i.alphaID,"description"]
        cell2 <- paste(paste(gsub("_","\\\\textunderscore ",CN),checkmarks,sep=""),collapse=", ")
        tend.int <- attributes(tab)$tendency
        tend <- "-"
        if (!is.na(tend.int)) {
          tend <- ifelse(tend.int > 0,"$\\Uparrow$",
                         ifelse(tend.int==0,"$\\Rightarrow$","$\\Downarrow$"))
        }
        cat(tend," & \\textbf{",item,"}: ",sanitize(cell1),
            " & ",cell2,"\\\\\n",sep="")
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
            file.path(tmpdir,texName),overwrite=TRUE)
  ## running pdflatex                                                     
  wd.orig <- getwd()                                                      
  setwd(tmpdir)                                                           
  texi2dvi(texName,pdf=TRUE)                                              
  setwd(wd.orig)
  ## moving resulting pdf to user's dir and
  ## deleting temporary directory
  file.copy(file.path(tmpdir,pdfName),userDir,overwrite=TRUE)                            
  ##unlink(tmpdir,recursive=TRUE)
  ## printing name of xml file to screen
  cat(pdfName)
} # else

