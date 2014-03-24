#!/usr/bin/Rscript
## SETTINGS
X <- c("Lesen","Schreiben","Sprache","Rechnen")
Y <- c(solved="Kannbeschreibungen erfüllt",
       partly="Kannbeschreibungen teilweise erfüllt",
       notsolved="Kannbeschreibungen nicht erfüllt")
graphics.files <- c("arrow_grey_down.png", "logo.pdf", "arrow_grey_right.png", "arrow_grey_up.png", "dot_grey.png")

args <- commandArgs(TRUE)
args <- "CWB8D" # !!! TESTING !!!
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
      x.data <- x$data
      ind <- nchar(x.data)> 0 # this one is needed for getting rid of empty data fields
      ans <- file.path(userDir,x.data[ind])
      names(ans) <- x$iname[ind]
      attributes(ans) <- c(attributes(ans),list(attrs=attributes(x)$attrs))
      ans})
    testresults
  }
  ## getting the marking sections of various testresult files
  ## and merge them into a data frame containing character strings
  ##testresult <- testresults[[3]]
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
    if (!is.null(markings.all)) {
      marks <- markings.all[,"mark"]
      markings.all[marks=="" | marks=="failed","mark"] <- 0
    }
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
  testresults
  markings <- lapply(testresults,getMarkings)
  markings <- markings[sapply(markings,nrow)>0] # some of them will be empty because of the mysterious data="" attribute
  layer0 <- lapply(markings,function(x) {
    rown <- nrow(x)
    a <- attributes(x)[c("timestamp.string","subject.string","level.string")]
    b <- matrix(rep(a,rown),nrow=rown,byrow=TRUE)
    colnames(b) <- names(a)
    cbind(b,x)
  })
  layer1 <- do.call("rbind",layer0)[,c(c("timestamp.string","subject.string","level.string","itemnumber","alphalevel","mark","task"))]
  ## creating a frequency table for the abilities
  abis <- do.call("c",tapply(as.character(layer1$alphalevel),as.character(layer1$timestamp.string),function(x) levels(as.factor(x))))
  abis.freq <- tapply(abis,as.factor(abis),length)
  ## Layer 2: sort by subject,alphalevel,itemnumber, then report last 2 marks for each itemnumber
  bysubject <- by(layer1[,c(1,7,4,5,6)],as.character(layer1$subject.string),function(x) x)
  ##head(bysubject$Lesen)
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
  #layer2.list$Sprache
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
  layer2$Sprache
  ## group alphalevels by category
  layer3 <- lapply(layer2,function(x) lapply(c(solved=10,partly=5,notsolved=0),function(i) x[sapply(x,function(x) attributes(x)$ctg==i)]))
  length(layer3$Rechnen$solved)*3
  systime <- Sys.time()
  baseName <- paste(user,format(systime,format="%Y%m%d_%H_%M_%S"),sep="_")
  baseName <- "systime" # !!! TESTING !!!
  baseName <- paste(baseName,"teacher",sep="_")
  pdfName <- paste(baseName,"pdf",sep=".")
  texName <- paste(baseName,"tex",sep=".")
  userDir <- "/tmp" # !!! TESTING !!!
  tmpdir <- file.path(userDir,baseName)
  if (!file.exists(tmpdir)) dir.create(tmpdir) # just to make sure
  ## creating tex tabulars
  alphalist.df <- alphalist2df(alphalist)
  pagenum <- 0
  ##y <- Y[1] # !!! TESTING !!!
  for (y in Y) { # looping through categories, each goes to a separate page
    catname <- names(Y)[Y==y]
    pagenum <- pagenum + 1
    sink(file.path(tmpdir,paste(catname,".tex",sep="")))
    cat("\\textline[t]{",toupper(y),"}{",pagenum,"}{",user,"}{",format(systime,format="%d.%m.%Y"),"} % printing header \n",sep="")
    cat("\\noindent{\\centering%\n")
    cat("% start of tikz graphics\n")
    cat("\\begin{tikzpicture}[x=0.01\\textwidth, y=1em]\n")
    ## background node
    cat("\\node[anchor=north west, inner sep=0] at (0,0) {%\n")
    cat("\\begin{tabular}{|wLwSwPwR|}\n")
    cat("\\hline\n")
    cat(paste(rep(paste("\\parbox[l][\\layoutheight][l]{",c("\\descwidth","\\taskwidth"),"}{\\quad}",sep=""),4),collapse=" & "),"\\\\\n")
    cat("\\hline\n")
    cat("\\end{tabular}\n")
    cat("};\n")
    ##x <- "Lesen" # !!! TESTING !!!
    for (x in X) {# this inner loop creates the data nodes
      x.upper <- toupper(x)
      cat("\\node [anchor=north west,inner sep=0] at (\\pos",x,") {% ",x.upper,"\n",sep="")
      cat("\\begin{tabular}{@{}l@{}@{}p{\\taskwidth}@{}}\n")
      cat("\\multicolumn{2}{l}{\\cellcolor{",x,"}\\quad}\\\\[-1ex]\n",sep="")
      cat("\\multicolumn{2}{l}{\\cellcolor{",x,"}\\large {\\color{",x,"-head}",x.upper,"}}\\\\[1.5ex]\n",sep="")
      cat("\\begin{tabular}{p{\\descwidth}}\\cellcolor{",x,"}\\textcolor{head-small}{\\small Kannbeschreibung}\\\\[.5ex]\\end{tabular} & \\multicolumn{1}{c}{\\cellcolor{",x,"-light}\\textcolor{head-small}{\\small Aufgabe}}\\\\\n",sep="")
      cat("\\begin{tabular}{l}\\quad\\end{tabular} & \\quad\\\\[-1ex]\n")
      ## another inner loop will follow here
      xy <- layer3[[x]][[catname]]
      ##emptytab <- length(xy)==0 # that's a chunk from a former version
      item <- names(xy)[1] # !!! TESTING !!!
      for (item in names(xy)) { # looping through ability IDs
        i.alphaID <- match(item,alphalist.df$alphaID)
        tab <- xy[[item]]
        ctg <- attributes(tab)$ctg
        CN <- names(tab)
        checkmarks <- sapply(tab,function(x) ifelse(x,"\\cm",""))
        cell1 <- sanitize(alphalist.df[i.alphaID,"description"])
        cell2 <- paste(gsub("_","\\\\textunderscore ",CN),checkmarks,sep="")
        tend.int <- attributes(tab)$tendency
        tend <- "\\dotthorben\\quad"
        if (!is.na(tend.int)) {
          tend <- ifelse(tend.int > 0,"\\arrowup\\quad",
                         ifelse(tend.int==0,"\\arrowright\\quad","\\arrowdown\\quad"))
        }
        testcount <- abis.freq[item] # !!! TESTING !!!
        cat("\\multicolumn{2}{l}{\\small ",tend,item," (",testcount,")}\\\\\n",sep="")
        cat("\\begin{tabular}[t]{p{\\descwidth}}{\\small ",cell1,"}\\end{tabular} & \\begin{tabular}[t]{l}",paste(paste("{\\scriptsize",cell2,"}\\\\[-1ex]",sep=""),collapse=" "),"\\end{tabular}\\\\\n",sep="")
      } # for (item in names(xy))
      cat("\\end{tabular}%\n")
      cat("};\n")
    } # for (x in X)

    cat("\\end{tikzpicture}}\n")
    sink()
  } # for (y in Y)
  
  ## copying template file to temporary directory 
  file.copy(file.path(dir.template,"feedback.tex"),
            file.path(tmpdir,texName),overwrite=TRUE)
  for (f in graphics.files) {
    file.copy(file.path(dir.template,f),tmpdir,overwrite=TRUE)
  }
  ## running pdflatex                                                     
  wd.orig <- getwd()                                                      
  setwd(tmpdir)                                                           
  texi2dvi(texName,pdf=TRUE)                                              
  setwd(wd.orig)
  ## moving resulting pdf to user's dir and
  ## deleting temporary directory
  file.copy(file.path(tmpdir,pdfName),userDir,overwrite=TRUE)             
  unlink(tmpdir,recursive=TRUE)
  ## printing name of xml file to screen
  cat(pdfName)
} # else
