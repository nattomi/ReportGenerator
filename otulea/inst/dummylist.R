## ADDING AN EXTRA DUMMY COLUMN TO THE EXISTING ALPHALIST.XML FILE
## alphalist file to be modified
al <- "www/data/item/alphalist/alphalist.XML"

## REQS
library(XML)

## MAIN
doc <- xmlParse(al)
r <- xmlRoot(doc)
## adding extra attribute
xmlSApply(r,function(x) xmlAttrs(x) <- c(xmlAttrs(x),sound="sound.ogg"))
## saving the file
sink(al)
r
sink()
