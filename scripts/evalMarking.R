#!/usr/bin/Rscript
## ARGUMENTS
suppressWarnings(suppressMessages(library(optparse)))
option_list <- list( # list of command line options
                    make_option(c("-m","--marking"),help="path of the marking file to be processed"),
                    make_option(c("-t","--threshold"),type="numeric",default=100, help="threshold for fullfilling a competency [defaults to %default]"),
                    make_option(c("-l","--maxlistings"),type="integer",default=3, help="max. number of listings in order to limit the output to a fixed set of reported competencies or needs for improvement [defaults to  %default]"),
                    make_option(c("-x","--xmltimestamp"),default="", help="timestamp string which goes to the xml result [defaults to \"\"]"),
                    make_option(c("-f","--filename"),default="", help="name of output file without extension [defaults to \"\", which means STDOUT]")
                    )
opt <- parse_args(OptionParser(option_list=option_list))
## REQUIREMENTS
suppressWarnings(suppressMessages(library(XML)))
## ROUTINES
## converts alphalist.XML to a data.frame  
alphalist2df <- function(alphalist) {
  if (is.character(alphalist)) alphalist <- xmlInternalTreeParse(alphalist)
  alphalist.list <- xmlToList(alphalist)
  alphalist.list <- alphalist.list[names(alphalist.list)=="alphanode"]
  ans <- data.frame(t(as.data.frame(alphalist.list)),stringsAsFactors=F)
  rownames(ans) <- NULL
  ans
}
## list all tests taken by a user
list.tests <- function(guf) {
  doc <- xmlParse(guf)
  ##doc.root <- xmlRoot(doc)
  tests <- getNodeSet(doc, "//test")
  tests
}
## tell the date a particular test was taken
test.date <- function(test) {
  ans <- strptime(xmlAttrs(test)["timestamp"],
                  format="%Y_%m_%d_%H_%M_%S")
  names(ans) <- NULL
  ans
}
## getting the last test taken
last <- function(tests) {
  tests.date <- do.call("c",lapply(tests,test.date))
  ## finding the index of the last test taken
  tests[which.max(order(tests.date))]
}
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
## getting testresults
testResults <- function(userDir,guf) {
  ## tests taken by the user (returned as an XMLNodeSet)
  tests <- list.tests(guf)
  tests.df <- lapply(tests,test2df)
  testresults <- lapply(tests.df, function(x) {
    x.data <- x$data
    ans <- file.path(userDir,x.data)
    ans[nchar(x.data)==0] <- NA
    names(ans) <- x$iname
    attributes(ans) <- c(attributes(ans),list(attrs=attributes(x)$attrs))
    ans})
  testresults
}
## getting the marking sections of various testresult files
## and merge them into a data frame containing character strings
getMarkings <- function(testresult) {
  markings <- lapply(testresult, function(x) {
    if (!is.na(x)) {
      x.parse <- xmlParse(x)
      x.marking <- getNodeSet(x.parse, "//marking")
      getNodeSet(x.marking[[1]],"//mark")
    } else list()
  })
  markings.all <- c()
  for (n in names(markings)) {
    markings.n <- markings[[n]]
    if (length(markings.n) > 0) {
      ans.n <- lapply(markings.n,function(x) c(task=n,xmlAttrs(x)[c("itemnumber","alphalevel")],mark=xmlValue(x)))
      ans.n <- do.call("rbind",ans.n)
      ## sanitizing erronous data
      marks <- ans.n[,"mark"]
      ans.n[marks=="" | marks=="failed","mark"] <- 0
    } else ans.n <- c()
    markings.all <- rbind(markings.all,ans.n)
  }
  ## this is for sanitizing erronous data
  ##marks <- markings.all[,"mark"]
  ##markings.all[marks=="" | marks=="failed","mark"] <- 0
  markings.df <- as.data.frame(markings.all)
  attributes(markings.df)<- c(attributes(markings.df),attributes(testresult)$attrs)
  markings.df
}

## alphalevels to be reported
getAlphalevels <- function(userDir,guf,threshold, maxListings,
                           alphalist.df,timestamp) {
  ## Information extraction
  ## getting testresults - FIXME: adding a mode argument?
  testresults <- testResults(userDir,guf)
  testresults.timestamp <- testresults[match(timestamp,sapply(testresults,function(x) attributes(x)$attrs[["timestamp.string"]]))]
  ## marking
  ##testresults <- testResults(userDir) # for testing!
  ##testreults <- testresults[1]
  ##testresults.timestamp
  markings <- lapply(testresults.timestamp,getMarkings)
  lastmarkings <- markings[[1]]
  ##lastmarkings <- getMarkings(testresults[[2]]) # for testing
  ##lastmarkings
  ## Derivation of results
  ## getting alphaID-s from the alphalist data frame
  alphaIDs <- sort(alphalist.df$alphaID) # this is most probably redundant
  ## all tested alphalevels
  if (nrow(lastmarkings) > 0) {
    thresholds <- tapply(as.integer(as.character(lastmarkings[,"mark"])),as.character(lastmarkings[,"alphalevel"]), mean)
    ##if (FALSE) {
    alphas.tested <- names(thresholds)
    ## which alphalevels are above and below the threshold?
    above <- thresholds >= threshold/100
    alphas.above <- alphas.tested[above]
    ## for A1 (Das kann ich) I only need to do an ordering and then filter according to maxListings
    ##ind.above <- alphaIDs %in% alphas.above
    if (length(alphas.above)>0) {
      df <- t(sapply(strsplit(alphas.above,"\\."),function(x) as.integer(x)))
      orderlist <- 1:ncol(df)
      orderind <- do.call("order",c(lapply(orderlist,function(x) df[,x]),list(decreasing=TRUE)))
      alphas.A1 <- alphas.above[orderind]
    } else {
      alphas.A1 <- alphas.above
    }
    ## for A2 (Das kann ich bald wenn ich noch ein wenig übe) I order by item, alphalevel. Take only the alphalevel and only those values which are not duplicates !!!FIXME!!! I should rewrite this with thersholds
    wronganswers <- lastmarkings[lastmarkings$mark==0,c("task","alphalevel")]
    ##wrong.task <- as.character(wronganswers$task)
    wrong.alpha <- unique(as.character(wronganswers$alphalevel))
    ##ind.order <- order(wrong.task,wrong.alpha,decreasing=FALSE)
    if (length(wrong.alpha)>0) {
      df <- t(sapply(strsplit(wrong.alpha,"\\."),function(x) as.integer(x)))
      orderlist <- 1:ncol(df)
      orderind <- do.call("order",c(lapply(orderlist,function(x) df[,x]),list(decreasing=FALSE)))
      alphas.A2 <- wrong.alpha[orderind]
    } else {
      alphas.A2 <- wrong.alpha
    }
    ##highest.alpha <- wrong.alpha[ind.order]
    ##alphas.A2 <- highest.alpha[!duplicated(highest.alpha)]
    ## result as list
    alphas <- list(A1=alphas.A1,A2=alphas.A2)
    ## limit the number of results
    alphas.limited <- lapply(alphas,function(x) head(x,maxListings))
    alphas.limited$A2 <- head(alphas.limited$A2,2) # that's a patch, we need only 2 values
  } else alphas.limited <- list()
  ## passing 'subject' and 'level' as attribute
  attrs <- lapply(testresults.timestamp,attributes)[[1]]
  attr(alphas.limited,"subject") <- attrs$attrs[["subject.string"]]
  attr(alphas.limited,"level") <- attrs$attrs[["level.string"]]
  alphas.limited
}
## BASED ON THE RESULT OF 'getAlphalevels' AND AN ALPHALIST DATA FRAME
## IT UNCOMPRESSES THE DESIRED COLUMNS AND ROWS OF THE ALPHALIST
uncompress <- function(x,alphalist.df=alphalist2df(alphalist),
                       subset=1:dim(alphalist.df)[2]) {
  ans <- lapply(x,function(x) alphalist.df[match(x,alphalist.df$alphaID),subset])
  attributes(ans) <- attributes(x)
  ans
}  
## FOR GETTING ALPHALEVELS ASSOCIATED TO 'A' TYPE EVALUATION MODES
alphalevels2xml <- function(uncprsd,file,xmlfile,ts,subject,level) {
  TAB <- "  "
  ##if (!file.exists(xmlfile)) file.create(xmlfile)
  cat("<results>\n",file=xmlfile)
  ## adding 'print' node
  cat(TAB,'<print file="',file,'"/>\n',sep="",file=xmlfile,append=TRUE)
  ## adding 'timestamp' node
  ##ts <- format(Sys.time(),"%Y%m%d%H%M%S")
  cat(TAB,'<timestamp order="YmdHis" value="',ts,'"/>\n',sep="",file=xmlfile,append=TRUE)
  ## adding 'subject' node
  cat(TAB,'<subject value="',subject,'"/>\n',sep="",file=xmlfile,append=TRUE)
  ## adding 'level' node
  cat(TAB,'<level value="',level,'"/>\n',sep="",file=xmlfile,append=TRUE)
  ## adding 'eval' nodes
  modes <- names(uncprsd)
  ##mode <- modes[[1]]
  for (mode in modes) {
    cat(TAB,'<eval mode="',mode,'"',sep="",file=xmlfile,append=TRUE)
    dat <- uncprsd[[mode]]
    nr <- nrow(dat)
    if (nr > 0) {
      cat('>\n',file=xmlfile,append=TRUE)
      r <- 1
      for (r in 1:nr) {
        cat(TAB,TAB,'<alphanode alphaID="',dat[r,"alphaID"],'" userdescription="',dat[r,"userdescription"],'" example="',dat[r,"example"],'"/>\n',sep="",file=xmlfile,append=TRUE)
      }
      cat(TAB,'</eval>\n',sep="",file=xmlfile,append=TRUE)   
    } else cat('/>\n',file=xmlfile,append=TRUE)
  }
  cat("</results>\n",file=xmlfile,append=TRUE)
}
## MAIN
user <- opt$user
userDir <- file.path(usersDir, user) # the user's folder
guf <- file.path(userDir,paste(user,"xml",sep=".")) # global user file
threshold <- opt$threshold
maxListings <- opt$maxlistings
timestamp <- opt$timestamp
if (timestamp=="") { # if "", it defaults to the last test
  tests <- list.tests(guf)
  timestamp <- xmlAttrs(last(tests)[[1]])[["timestamp"]]
}
filename <- opt$filename
alphalist.df <- alphalist2df(alphalist) # this one just converts the alphalist xml to a df
## evaluation phase
alphalevels_pro_mode <- getAlphalevels(userDir,guf,threshold,maxListings,alphalist.df,timestamp)
subject <- attr(alphalevels_pro_mode,"subject")
level <- attr(alphalevels_pro_mode,"level")
tables_pro_mode <- uncompress(alphalevels_pro_mode,alphalist.df,c("userdescription","example","alphaID")) ## does a lookup in alphalist df and reports tabular information
xmlName <- paste(filename,ifelse(filename!="",".xml",""),sep="")
pdfName <- paste(basename(filename),"pdf",sep=".")
alphalevels2xml(tables_pro_mode,file=pdfName,
                xmlfile=xmlName,
                ts=opt$xmltimestamp,
                subject=subject,level=level)
