#!/usr/bin/Rscript
args <- commandArgs(TRUE)
args <- "KFCG1"
if (length(args)==0) {
  cat("Usage: teacherReport.R user\n")
  cat("where\n")
  cat("* user: user Number\n")
  cat("Example: teacherReport.R 6CKBT\n")
} else {
  ## REQUIREMENTS
  require(XML)
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
    markings.df <- as.data.frame(do.call("rbind",markings.all2))
    attributes(markings.df)<- c(attributes(markings.df),attributes(testresults))
    markings.df
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
  layer1 <- do.call("rbind",layer0)[,c(c("timestamp.string","subject.string","itemnumber","alphalevel","mark"))]
  layer1$mark[layer1$mark==""] <- 0 # we don't want any empty mark value
  layer1$mark[layer1$mark=="failed"] <- 0 # we don't want "failed" as a mark value
  ## Layer 2: extend tabular form with information about categories
  bysubject <- by(layer1,as.character(layer1$subject.string),function(x) x)
  layer2.list <- lapply(bysubject,function(x) { # sorts elements by subject
    y <- by(x[,c("timestamp.string","mark")],as.character(x$itemnumber),function(x) x) # sorts elements belonging to a subject by itemnumber
    lapply(y,function(x) { # calculating n, tendency and category for a certain itemnumber
      ## At this point, x looks like this:
      ##      timestamp.string mark
      ##69  2014_2_27_18_37_23    1
      ##70  2014_2_27_18_37_23    1
      ##347  2014_3_3_20_32_49    1
      ##348  2014_3_3_20_32_49    1
      n <- nrow(x)
      bydate <- tapply(x$mark,as.character(x$timestamp.string),function(x) as.integer(as.character(x))) ## sorting mark values by date (this way we get a list of dates, each element of this list is a vector of mark values. !!!NOTE!!! At the moment I assumed that the length of the vector is always the same. 
      ind.latests <- order(strptime(names(bydate),format="%Y_%m_%d_%H_%M_%S",tz="GMT"),decreasing=TRUE) 
      latest <- as.integer(as.character(bydate[[ind.latests[1]]])) ## the vector of latest latest mark values for a certain itemnumber
      tendency <- NA # if the itemnumber was tested only in one test, i.e. bydate is a list of length 1, then the tendency is NA
      if (length(bydate) > 1) { # if the length of bydate is at least 2, then we caculate tendency by comparing the vectors 'latest' and 'before.latest'. !!!NOTE!!! this is an elementwise comparision, but at the moment I can't be sure that in the 2 vectors the elements are in the same order! For that purpose probably I would have to use the alphalevel item as well. 
        before.latest <- as.integer(as.character(bydate[[ind.latests[2]]]))
        if (all(before.latest <= latest)) {
          tendency <- ifelse(all(before.latest==latest),0,1)
        } else if (all(latest <= before.latest)) tendency <- -1
      }
      ## It remains to calculate the category
      ctg <- 10 
      if (any(latest==0)) { 
        ctg <- ifelse(all(latest==0),0,5)
      }
      c(n=n,tendency=tendency,category=ctg)
    })
  })
  ##head(layer2.list$Lesen)
  ##layer2.list
  layer2 <- cbind(layer1,t(apply(layer1,1,function(x) layer2.list[[x[2]]][[x[3]]])))
  ##write.table(layer2,"/tmp/tmp.txt")
  ##layer2$category
  print(layer2)
}
