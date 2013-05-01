#!/usr/bin/Rscript
args <- commandArgs(TRUE)
if (length(args)==0) {
  cat("Usage: teacherReport.R user\n")
  cat("where\n")
  cat("* user: user Number\n")
  cat("Example: studentReport.R 6CKBT 50 3\n")
} else {
  require(otulea)
  ##require(tools)
  user <- as.character(args[1])
  testresults <- testResults(user)
  print(testresults)
  markings <- lapply(testresults,getMarkings)
  print(markings)
  if (FALSE) {
  markings <- lapply(testresults,getMarkings)
  ## Derivation of results
  user <- as.character(args[1])
  ##user <- "6CKBT" ## user id as character string
  threshold <- as.numeric(args[2])
  ##threshold <- 50 ## percentage
  maxListings <- as.integer(args[3])
  ##maxListings <- 3 ## maximal number of results listed
  alphalist.df <- alphalist2df(alphalist) ## this one just converts the alphalist xml to a df
  ## student report generation
  alphalevels_pro_mode <- getAlphalevelsA(user,threshold,maxListings,alphalist.df) ## this one just reports corresponding alphalevels for each eval mode
  subject <- attr(alphalevels_pro_mode,"subject")
  level <- attr(alphalevels_pro_mode,"level")
  cellcolor <- as.character(cellcolors$color[match(subject,cellcolors$subject)])
  tables_pro_mode <- uncompress(alphalevels_pro_mode,alphalist.df,c("userdescription","example","alphaID","sound")) ## does a lookup in alphalist df and reports tabular information
  systime <- Sys.time()
  baseName <- paste(user,format(systime,format="%Y%m%d_%H_%M_%S"),sep="_")
  texName <- paste(baseName,"tex",sep=".")
  pdfName <- paste(baseName,"pdf",sep=".")
  xmlName <- paste(baseName,"xml",sep=".")
  xml_output <- alphalevels2xml(tables_pro_mode,file=pdfName,
                                subject=subject,level=level)
  ## creating tex files
  dir.create(baseName)
  for (mode in paste("A",1:3,sep="")) {
    row.of.mode <- match(mode,modes$mode)
    mode.string <- as.character(modes$mode.string[row.of.mode])
    graphics.command <- paste("\\",as.character(modes$graphics[row.of.mode]),sep="")
    texIncludePath <- file.path(baseName,mode)
    sink(texIncludePath)
    feedback2tex(tables_pro_mode[[mode]],subject,mode.string,
                 graphics.command,cellcolor)
    sink()
  }
  ## copying template files
  for (f in templateFiles) {
    file.copy(f,baseName)
  }
  invisible(file.rename(file.path(baseName,basename(templateFiles[["userfeedback"]])),file.path(baseName,texName)))
  ## running pdflatex
  wd.orig <- getwd()
  setwd(baseName)
  texi2dvi(texName,pdf=TRUE)
  setwd(wd.orig)
  ## cleaning up
  invisible(file.copy(file.path(baseName,pdfName),wd.orig))
  unlink(baseName,recursive=TRUE)
  ## dumping xml output
  sink(xmlName)
  print(xml_output)
  sink()
}
}
