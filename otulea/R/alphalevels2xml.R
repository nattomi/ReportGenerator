## FOR GETTING ALPHALEVELS ASSOCIATED TO 'A' TYPE EVALUATION MODES

## EXAMPLES
if (FALSE) {
library(otulea)
user <- "6CKBT" ## user id as character string
threshold <- 50 ## percentage
maxListings <- 3 ## maximal number of results listed
alphalist.df <- alphalist2df(alphalist)
x <- getAlphalevels(user,threshold,maxListings,alphalist.df)
uncprsd <- uncompress(x,alphalist.df,c("userdescription","example","sound","alphaID"))

file <- "20120504_14_13_X0AT2.pdf"
subject <- attr(x,"subject")
level <- attr(x,"level")
result <- alphalevels2xml(uncprsd,file,subject, level)
result
## saving it to a file
write(saveXML(result),file=tempfile())
}


## FUNCTION
alphalevels2xml <- function(uncprsd,file,subject,level) {
  node <- newXMLNode("results")
  ## adding 'print' node
  newXMLNode("print",parent = node, attrs=c("file" = file))
  ## adding 'timestamp' node
  ts <- format(Sys.time(),"%Y%m%d%H%M%S")
  newXMLNode("timestamp", parent = node, attrs=c("order" = "YMDhms", "value" = ts))
  ## adding 'subject' node
  newXMLNode("subject", parent = node, attrs=c("value" = subject))
  ## adding 'level' node
  newXMLNode("level", parent = node, attrs=c("value" = level))
  ## adding 'eval' nodes
  modes <- names(uncprsd)
  mode <- modes[[1]]
  for (mode in modes) {
    nodeName <- paste("mode",mode,sep=".")
    assign(nodeName, newXMLNode("eval", parent = node, attrs=c("mode" = mode)))
    ## innen kell módosítani
    ##uncprsd[[mode.i]]
    ##trans <- function(x,y) pastenewXMLNode("alphannode", parent=',nodeName,', attrs=c("alphaID" = y)))',sep="")

    ##(uncprsd[[mode.i]],function(x) paste())
    dat <- uncprsd[[mode]]
    ##length(t(dat))
    ##as.data.frame(t(dat))
    text <- paste('lapply(as.data.frame(t(dat)),function(x) newXMLNode("alphanode", parent=',nodeName,', attrs=c("alphaID" = as.character(x[["alphaID"]]),"sound" = as.character(x[["sound"]]))))',sep="")
    eval(parse(text=text))
  }
  node
}

