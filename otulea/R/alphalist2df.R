## converts alphalist.XML to a data.frame  

## EXAMPLE
if (FALSE) {
require(XML)
alphalist <- system.file("www/data/item/alphalist/alphalist.XML",package="otulea")
alphalist2df(alphalist)
docTree <- xmlInternalTreeParse(alphalist)
alphalist2df(docTree)
}

alphalist2df <- function(alphalist) {
  if (is.character(alphalist)) alphalist <- xmlInternalTreeParse(alphalist)
  alphalist.list <- xmlToList(alphalist)
  alphalist.list <- alphalist.list[names(alphalist.list)=="alphanode"]
  ans <- data.frame(t(as.data.frame(alphalist.list)),stringsAsFactors=F)
  rownames(ans) <- NULL
  ans
}

