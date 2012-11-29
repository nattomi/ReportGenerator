## EXAMPLE
if (FALSE) {
library(otulea)
library(tools)
## redefining configuration settings
usersDir <- "../inst/www/data/user" # directory containing user folders
alphalist <- "../inst/www/data/item/alphalist/alphalist.xml"; alphalist.df <- alphalist2df(alphalist) # path to alphalist xml 
## arguments
user <- "6CKBT" # user id
threshold <- 10 # threshold in %
maxListings <- 3 # maximum number of results
dir.template <- "../inst/www/feedback/template" # directory contaning latex template
dir.feedback <- "/tmp/feedback" # directory containing feedback folders
## function call
genReportA(user,threshold,maxListings,alphalist.df,
           dir.template,dir.feedback)
}

getwd()
## FUNCTION
genReportA <- function(user,threshold,maxListings,alphalist.df,
                       dir.template,dir.feedback) {
  ## the actual calculation
  alphalevels <- getAlphalevels(user,threshold,maxListings,alphalist.df)
  subject <- attr(alphalevels,"subject")
  level <- attr(alphalevels,"level")
  cellcolor <- as.character(cellcolors$color[match(subject,cellcolors$subject)])
  ## this is for the file download
  systime <- Sys.time()
  baseName <- paste(user,format(systime,format="%Y%m%d_%H_%M_%S"),sep="_")
  dir.show <- file.path(dir.feedback, baseName)
  ## create directories if necessary
  if (!file.exists(dir.show)) dir.create(dir.show)

  ## basename of pdf file to be generated
  texName <- paste(baseName,"tex",sep=".")
  pdfName <- paste(baseName,"pdf",sep=".")
  uncprsd <- uncompress(x=alphalevels,alphalist.df=alphalist.df,subset=c("userdescription","example",
                                                                  "alphaID","sound"))
  ##print(uncprsd)
  templateFiles <- c(userfeedback="userfeedback.tex",
                     haken="haken.pdf",
                     leiter="leiter.pdf")
  ## copying template files
  for (f in templateFiles) {
    file.copy(file.path(dir.template,f),
              file.path(dir.show,f))
  }

  ## creating tex files
  for (mode in paste("A",1:3,sep="")) {
    row.of.mode <- match(mode,modes$mode)
    mode.string <- as.character(modes$mode.string[row.of.mode])
    graphics.command <- paste("\\",as.character(modes$graphics[row.of.mode]),
                              sep="")
    texIncludePath <- file.path(dir.show,mode)
    sink(texIncludePath)
    feedback2tex(uncprsd[[mode]],subject,mode.string,
                 graphics.command,cellcolor)
    sink()
  }
  ## renaming main tex file
  file.rename(file.path(dir.show,templateFiles[["userfeedback"]]),
              file.path(dir.show,texName))
  ## creating pdf file
  currentWD <- getwd()
  setwd(dir.show)
  texi2dvi(texName,pdf=TRUE)
  ## cleaning up
  unlink(x=file.path(dir.show,
           c(paste(baseName,c(".log",".aux",".tex"),sep=""),
             "A1","A2","A3","haken.pdf","leiter.pdf")))
  ## changing back to original working directory
  setwd(currentWD)
  ans <- alphalevels2xml(uncprsd,file=pdfName,subject,level)
  cat(saveXML(ans))
}
