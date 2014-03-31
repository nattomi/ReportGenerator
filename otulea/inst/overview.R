#!/usr/bin/Rscript
## SETTINGS
X <- c("Lesen","Schreiben","Sprache","Rechnen")
Y <- c(solved="Kannbeschreibungen erfüllt",
       partly="Kannbeschreibungen teilweise erfüllt",
       notsolved="Kannbeschreibungen nicht erfüllt")
graphics.files <- c("arrow_grey_down.png", "logo.pdf", "arrow_grey_right.png", "arrow_grey_up.png", "dot_grey.png")
hmax <- 8 # we break the page above that
  
args <- commandArgs(TRUE)
args <- "" # !!! TESTING !!!
if (length(args)==0) {
  cat("Usage: overview.R users\n")
  cat("where\n")
  cat("* users: folder contaning users' folders\n")
  cat("Example: overview.R /tmp/otulea/users\n")
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
  
  ## MAIN
  ## Layer 1: xml to tabular form
  usersDir <- as.character(args[1])
  users <- list.files(usersDir)
  names(users) <- users
  marksByUser <- lapply(users,function(user) {
    userDir <- file.path(usersDir,user) # the user's folder
    guf <- file.path(userDir,paste(user,"xml",sep=".")) # global user file
    testresults <- testResults(userDir,guf)
    markings <- lapply(testresults,getMarkings)
    markings <- markings[sapply(markings,nrow)>0] # some of them will be empty because of the mysterious data="" attribute
    layer0 <- lapply(markings,function(x) {
      rown <- nrow(x)
      a <- attributes(x)[c("timestamp.string","subject.string","level.string")]
      b <- matrix(rep(a,rown),nrow=rown,byrow=TRUE)
      colnames(b) <- names(a)
      cbind(b,x)
    })
    layer0
    layer1 <- do.call("rbind",layer0)[,c(c("itemnumber","mark"))]
    layer1
  })
  marksByUser
  ## List of item numbers answered by at least one user
  itemsAnswered <- levels(as.factor(do.call("c",lapply(marksByUser,function(x) levels(x$itemnumber)))))
  itemsAnswered.length <- length(itemsAnswered)
  ans <- sapply(users,function(u) {
    marksByUser.u <- marksByUser[[u]]
    ans <- rep(NA,itemsAnswered.length)
    names(ans) <- itemsAnswered
    ans[as.character(marksByUser.u$itemnumber)] <- as.character(marksByUser.u$mark)
    ans
  })
  write.csv(t(ans),file="overview.csv",row.names=TRUE,quote=FALSE)
} # else 
