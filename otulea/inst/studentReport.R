#!/usr/bin/Rscript
## SETTINGS
modes <- c("A1","A2")
modes.string <- c(A1="Das kann ich!",A2="Das kann ich bald wenn ich noch ein wenig übe.")
graphics <- c("haken","leiter")
graphics.files <- c("haken.pdf", "leiter.pdf")
welldone <- c(Einfach="Sehr gut, Sie haben alle Aufgaben gelöst! Machen Sie weiter mit dem mittleren Niveau!",
              Mittel="Sehr gut, Sie haben alle Aufgaben gelöst! Machen Sie weiter mit dem schwierigen Niveau!",
              Schwer=" Sehr gut, Sie haben alle Aufgaben gelöst!")
args <- commandArgs(TRUE)
args <- "KFCG1"
nargs <- length(args)
if (nargs==0) {
  cat("Usage: studentReport.R user threshold maxListings\n")
  cat("where\n")
  cat("* user: user Number\n")
  cat("* threshold: threshold for fullfilling a competency\n")
  cat("* maxListings: max. number of listings (to limit the output to a fixed set of reported competencies or needs for improvement)\n")
  cat("Example: studentReport.R 6CKBT 50 3\n")
} else {
  ## REQUIREMENTS
  #t0 <- Sys.time()
  require(XML)
  require(tools)
  #t1 <- Sys.time()
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
  testResults <- function(userDir,last=FALSE) {
    ## location of global user file
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
  ##testresults <- testresults[[1]]
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

  ## alphalevels to be reported
  getAlphalevels <- function(userDir, threshold, maxListings,
                             alphalist.df) {
    ## Information extraction
    ## getting testresults - FIXME: adding a mode argument?
    testresults <- testResults(userDir,TRUE)
    ## marking
    markings <- lapply(testresults,getMarkings)
    lastmarkings <- markings[[1]]
    ## Derivation of results
    ## getting alphaID-s from the alphalist data frame
    alphaIDs <- sort(alphalist.df$alphaID)
    ## all tested alphalevels
    thresholds <- tapply(as.integer(as.character(lastmarkings[,"mark"])),as.character(lastmarkings[,"alphalevel"]), mean)
    alphas.tested <- names(thresholds)
    ## which alphalevels are above and below the threshold?
    above <- thresholds >= threshold/100
    alphas.above <- alphas.tested[above]
    ## for A1 (Das kann ich) I only need to do an ordering and then filter according to maxListings
    ind.above <- alphaIDs %in% alphas.above
    alphas.A1 <- sort(alphas.above,decreasing=TRUE)
    ## for A2 (Das kann ich bald wenn ich noch ein wenig üben) I order by item, alphalevel. Take only the alphalevel and only those values which are not duplicates !!!FIXME!!! I should rewrite this with thersholds
    wronganswers <- lastmarkings[lastmarkings$mark==0,1:2]
    wrong.item <- as.character(wronganswers$itemnumber)
    wrong.alpha <- as.character(wronganswers$alphalevel)
    ind.order <- order(wrong.item,wrong.alpha,decreasing=TRUE)
    highest.alpha <- wrong.alpha[ind.order]
    alphas.A2 <- highest.alpha[!duplicated(highest.alpha)]
    ## result as list
    alphas <- list(A1=alphas.A1,A2=alphas.A2)
    ## limit the number of results
    alphas.limited <- lapply(alphas,function(x) head(x,maxListings))
    ## passing 'subject' and 'level' as attribute
    attrs <- lapply(testresults,attributes)[[1]]
    attrs
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
  ## PROVIDED THAT WE HAVE A DATA.FRAME AT LEAST WITH COLUMNS
  ## "userdescription" AND "example" THIS FUNCTION CREATES THE LATEX
  ## SOURCE NEEDED FOR INCLUSION IN THE MAIN USER FEEDBACK FILE
  ##x <- tables_pro_mode[["A1"]] # for testing only
  feedback2tex <- function(x,subject, mode, graphics.command) {
    if (missing(x)) {
      ## if the first argument is missing then we enter into demo mode
      cat(paste(paste(template_default,collapse="\n"),"\n"))
    } else {
      ## number of rows
      rownum <- dim(x)[1]
      ##rownum <- 0 # for testing only
      if (rownum > 0) {
        ## this one goes to the title row
        cat("\\feedback{\n")
        cat("{\\tiny\\textline[t]{",user,"}{\\normalsize ",subject,"}{",level,"}}\n",sep="")
        cat("\\hrule\n")
        cat("\\vspace{1em}\n")
        ##x$example[c(2,3,5)] <- "Let's pretend we have some content here" # for testing only
        x.sub <- cbind(graphics=paste("\\scalebox{0.8}{",graphics.command,"}",sep=""),x[,c("userdescription","example")])
        cellcolor <- paste("\\cellcolor{",subject,"}",sep="")
        ## in the following loop we calculate which table borders should be drawn in the 3rd column
        ## initial hhline value
        ISEMPTY <- sapply(x$example,function(x) nchar(x)==0)
        hhline <- paste("\\hhline{",ifelse(ISEMPTY[1],"--~","---"),"}",sep="")
        align <- c()
        for (i in 1:rownum) {
          ## hhline
          hhline[i+1] <- hhline[i]
          isempty <- ISEMPTY[i]
          isempty.next <- TRUE
          if (i<rownum) isempty.next <- ISEMPTY[i+1]
          firsttwo <- ifelse(i<rownum,"==","--")
          if (isempty) {
            if (isempty.next) {
              third <- "~"
            } else {
              third <- "-"
            }
            cline <- ""
            align[i] <- "{m{300pt}}{"
          } else {
            if (isempty.next) {
              third <- "~"
              cline <- "\\cline{3-3}"
            } else {
              third <- "="
              cline <- ""
            }
            align[i] <- paste("{m{300pt}|}{",cellcolor,sep="")
          }
          hhline[i+1] <- paste(cline,"\\hhline{",firsttwo,third,"}",sep="")
        }
        ## we don't print "Beispiel" when there is nothing to print
        beispiel <- ifelse(all(ISEMPTY),"","Beispiel")
        cat("{\\small\n") # setting font size to small
        cat("\\begin{tabular}{|m{80pt}|m{300pt}|m{300pt}|}\n")
        cat("\\multicolumn{2}{m{380pt}}{\\tiny ",modes.string[[mode]],"} & \\multicolumn{1}{l}{\\tiny ",beispiel,"}\\\\",sep="")
        cat(hhline[1],"\n")    
        for (i in 1:rownum) {
          cat(cellcolor,as.character(x.sub[i,"graphics"])," & ",cellcolor," ",as.character(x.sub[i,"userdescription"])," & \\multicolumn{1}",align[i]," ",as.character(x.sub[i,"example"]),"}\\\\",sep="")
        cat(hhline[i+1],"\n")
        }
        cat("\n\\end{tabular}\n")
        cat("}}\n")
      } else {
        if (mode=="A2"){
          cat("\\feedback{\n") 
          cat("{\\tiny\\textline[t]{",user,"}{\\normalsize ",subject,"}{",level,"}}\n",sep="") # slightly redundant
          cat("\\hrule\n") # slightly redundant
          cat("\\vspace{1em}\n") # sligthly redundant
          cat(welldone[[level]],"}\n",sep="")
        }
      }
    }
  }
  ## FOR GETTING ALPHALEVELS ASSOCIATED TO 'A' TYPE EVALUATION MODES
  alphalevels2xml <- function(uncprsd,file,subject,level) {
    TAB <- "  "
    cat("<results>\n")
    ## adding 'print' node
    cat(TAB,'<print file="',file,'"/>\n',sep="")
    ## adding 'timestamp' node
    ts <- format(Sys.time(),"%Y%m%d%H%M%S")
    cat(TAB,'<timestamp order="YMDhms" value="',ts,'"/>\n',sep="")
    ## adding 'subject' node
    cat(TAB,'<subject value="',subject,'"/>\n',sep="")
    ## adding 'level' node
    cat(TAB,'<level value="',level,'"/>\n',sep="")
    ## adding 'eval' nodes
    modes <- names(uncprsd)
    ##mode <- modes[[1]]
    for (mode in modes) {
      cat(TAB,'<eval mode="',mode,'"',sep="")
      dat <- uncprsd[[mode]]
      nr <- nrow(dat)
      if (nr > 0) {
        cat('>\n')
        r <- 1
        for (r in 1:nr) {
          cat(TAB,TAB,'<alphanode alphaID="',dat[r,"alphaID"],'" userdescription="',dat[r,"userdescription"],'" example="',dat[r,"example"],'">\n',sep="")
        }
        cat(TAB,'</eval>\n',sep="")   
      } else cat('/>\n')
    }
    cat("</results>\n")
  }
  ## MAIN  
  user <- as.character(args[1])
  ##user <- "6CKBT" ## user id as character string
  threshold <- as.numeric(args[2])
  threshold <- 50 # testing only
  maxListings <- as.integer(args[3])
  maxListings <- 5 # testing only
  debug <- FALSE
  if (nargs > 3) debug <- as.character(args[4])
  ##maxListings <- 3 ## maximal number of results listed
  alphalist.df <- alphalist2df(alphalist) # this one just converts the alphalist xml to a df
  userDir <- file.path(usersDir, user) # the user's folder
  ## student report generation
  alphalevels_pro_mode <- getAlphalevels(userDir,threshold,maxListings,alphalist.df) ## this one just reports corresponding alphalevels for each eval mode
  subject <- attr(alphalevels_pro_mode,"subject")
  level <- attr(alphalevels_pro_mode,"level")
  ##cellcolor <- as.character(cellcolors$color[match(subject,cellcolors$subject)]) # probably I can replace it
  tables_pro_mode <- uncompress(alphalevels_pro_mode,alphalist.df,c("userdescription","example","alphaID")) ## does a lookup in alphalist df and reports tabular information
  systime <- Sys.time()
  baseName <- paste(user,format(systime,format="%Y%m%d_%H_%M_%S"),sep="_")
  baseName <- paste(baseName,"result",sep="_")
  baseName <- "baseName" # for testing only
  texName <- paste(baseName,"tex",sep=".")
  pdfName <- paste(baseName,"pdf",sep=".")
  xmlName <- paste(baseName,"xml",sep=".")
  if (debug) cat("XML output created\n")
  #t2 <- Sys.time()
  ## creating tex files
  userDir <- "/tmp" # for testing only
  tmpdir <- file.path(userDir,baseName)
  success <- dir.create(tmpdir)
  if (debug) cat(success,tmpdir,"\n")
  ##mode <- "A1" # for testing only
  sink(file.path(tmpdir,"modes.tex"))
  for (mode in paste("A",1:2,sep="")) {
    row.of.mode <- match(mode,modes)
    ##mode.string <- modes.string[row.of.mode]
    graphics.command <- paste("\\",graphics[row.of.mode],sep="")
    x <- tables_pro_mode[[mode]]
    feedback2tex(tables_pro_mode[[mode]],subject,mode,
                 graphics.command)
  }
  sink()
  #t3 <- Sys.time()
  ## copying template file to temporary directory 
  file.copy(file.path(dir.template,"userfeedback.tex"),
            file.path(tmpdir,texName),overwrite=TRUE)
  for (f in graphics.files) {
    file.copy(file.path(dir.template,f),tmpdir,overwrite=TRUE)
  }
  ## running pdflatex
  wd.orig <- getwd()
  setwd(tmpdir)
  texi2dvi(texName,pdf=TRUE)
  setwd(wd.orig)
  #t4 <- Sys.time()
  ## cleaning up
  #if (debug) cat(file.path())
  file.copy(file.path(tmpdir,pdfName),userDir)
  ##unlink(tmpdir,recursive=TRUE)
  ## dumping xml output
  sink(file.path(userDir,xmlName))
  alphalevels2xml(tables_pro_mode,file=pdfName,
                  subject=subject,level=level)
  sink()
  ## printing name of xml file to screen
  cat(xmlName)
  ##  t5 <- Sys.time()
  ##write(c(t1,t2,t3,t4,t5)-t0,"/tmp/speed.log") # monitoring speed
}
