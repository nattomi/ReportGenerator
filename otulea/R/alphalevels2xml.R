## FOR GETTING ALPHALEVELS ASSOCIATED TO 'A' TYPE EVALUATION MODES

## EXAMPLES
if (FALSE) {
library(otulea)
user <- "6CKBT" ## user id as character string
threshold <- 50 ## percentage
maxListings <- 3 ## maximal number of results listed
alphalevels <- getAlphalevels(user,threshold,maxListings)
file <- "20120504_14_13_X0AT2.pdf"
dimension <- 2
level <- 1
result <- alphalevels2xml(alphalevels,file,dimension, level)
result
## saving it to a file
write(saveXML(result),file=tempfile())
}


## FUNCTION
alphalevels2xml <- function(alphalevels,file,dimension,level) {
  node <- newXMLNode("results")
  ## adding 'print' node
  newXMLNode("print",parent = node, attrs=c("file" = file))
  ## adding 'timestamp' node
  ts <- format(Sys.time(),"%Y%m%d%H%M%S")
  newXMLNode("timestamp", parent = node, attrs=c("order" = "YMDhms", "value" = ts))
  ## adding 'dimension' node
  newXMLNode("dimension", parent = node, attrs=c("dimension" = dimension))
  ## adding 'level' node
  newXMLNode("level", parent = node, attrs=c("level" = level))
  ## adding 'eval' nodes
  modes <- names(alphalevels)
  ##i <- 1
  for (i in 1:3) {
    mode <- modes[i]
    nodeName <- paste("mode",mode,sep=".")
    assign(nodeName, newXMLNode("eval", parent = node, attrs=c("mode" = mode)))
    text <- paste('sapply(alphalevels[[i]],function(y) newXMLNode("alphaid", parent=',nodeName,', attrs=c("value" = y)))',sep="")
    eval(parse(text=text))
  }
  node
}

