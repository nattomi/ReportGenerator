## converts alphalist.XML to a data.frame  

## EXAMPLE
if (FALSE) {
require(XML)
alphalistXML <- system.file("www/data/item/alphalist/alphalist.XML",package="otulea")
docTree <- xmlInternalTreeParse(alphalistXML)
alphalist2df(docTree)
}

alphalist2df <- function(docTree) {
  alphalist.list <- xmlToList(docTree)
  alphalist.list <- alphalist.list[names(alphalist.list)=="alphanode"]
  ans <- data.frame(t(as.data.frame(alphalist.list)),stringsAsFactors=F)
  rownames(ans) <- NULL
  ans
}

